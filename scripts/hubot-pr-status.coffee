# Description:
#  This script provides three commands to work with open Github PRs on a
#  per-project basis
#
#  Dependencies:
#    "hubot": "2.5.5",
#    "hubot-slack": "^3.3.0",
#    "octokat": "^0.4.11",
#    "q": "^1.4.1",
#    "underscore": "^1.8.3"
#
# Configuration:
#   HUBOT_SLACK_TOKEN - API token for this bot user (Refer README on how to obtain this)
#   GH_AUTH_TOKEN - A Github token for this bot user (Refer README on how to obtain this)
#
# Commands:
#   hubot pr org/repo all - Shows a summary of all open PRs of this project
#   hubot pr org/repo <username> - Shows a summary of PRs opened by/assigned to this GitHub user
#   hubot pr org/repo conflicts - Shows a summary of all PRs with a merge conflict
slackToken  = process.env.HUBOT_SLACK_TOKEN
ghAuthToken = process.env.GH_AUTH_TOKEN

if !(slackToken and ghAuthToken)
  error =
    "\n
    Oops!\n
    Looks like some required environment variables are missing. Please refer to\n
    the README to know how to obtain these variables, if you haven't alredy got\n
    them. The necessary variables are:\n\n

      HUBOT_SLACK_TOKEN\n
      GH_AUTH_TOKEN\n

    Exiting now\n
    "

  console.log error
  process.exit(1)

PrAll       = require("../src/pr_all.coffee")
PrConflicts = require("../src/pr_conflicts.coffee")
PrUser      = require("../src/pr_user.coffee")
PostMergeHook   = require("../src/post_merge_hook.coffee")

module.exports = (robot) ->

  # Matches:
  #
  # @bot pr org/repo all
  # bot pr org/repo all
  #
  # Doesn't match:
  #
  # <garbage> @bot pr org/repo all <garbage>
  # <garbage> bot pr org/repo all <garbage>
  #
  # <garbage> @bot pr org/repo all
  # <garbage> bot pr org/repo all
  #
  # @bot pr org/repo all <garbage>
  # bot pr org/repo all <garbage>
  #
  # Test: http://rubular.com/r/1HXUQVxr8Z
  robot.respond /pr\u0020(.+)\/(.+)\u0020(\w+)/, (resp) ->
    org = resp.match[1]
    repo    = resp.match[2]
    command = resp.match[3]

    # TODO: Throw error if no org/repo is specified
    switch command
      when "all"
        robot.emit "PrAll",
          room: resp.message.room
          org: org
          repo: repo

      when "conflicts", "conflict"
        robot.emit "PrConflicts",
          room: resp.message.room
          org: org
          repo: repo

      # TODO: Get rid of this
      when "help"
        robot.emit "help", { room: resp.message.room }

      else
        robot.emit "PrUser",
          username: command
          room: resp.message.room
          org: org
          repo: repo

  robot.on "help", (metadata) ->
    message = {
      channel: metadata.room
      text: "Try running `@bot help` to view commands"
      mrkdwn_in: ["text"]
    }
    robot.adapter.customMessage message

  robot.on "PrConflicts", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"

    prConflicts = new PrConflicts(metadata.org, metadata.repo)
    prConflicts.generateMessage().then (message) =>
      # Slack ignores empty array for attachments, so this works even if the
      # message doesn't have any attachments
      msgData = {
        channel: metadata.room
        text: message.text
        attachments: message.attachments
      }
      robot.adapter.customMessage msgData

  robot.on "PrUser", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"

    prUser = new PrUser(metadata.username, metadata.org, metadata.repo)
    prUser.generateMessage().then (message) =>
      # Slack ignores empty array for attachments, so this works even if the
      # message doesn't have any attachments
      msgData = {
        channel: metadata.room
        text: message.text
        attachments: message.attachments
      }

      robot.adapter.customMessage msgData

  robot.on "PrAll", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"

    prAll = new PrAll(metadata.org, metadata.repo)
    prAll.generateSummary().then (summary) =>
      msgData = {
        channel: metadata.room
        text: summary
      }
      robot.adapter.customMessage msgData

  robot.router.post '/hubot/hook', (req, res) ->
    data   = if req.body.payload? then JSON.parse req.body.payload else req.body
    # This is either `opened` or `closed`. We'd need to check the merge status
    # everytime a PR is closed and merged. The `merged` key gives us the second
    # piece of information.
    pr_action    = data.action
    closedPr     = data.pull_request
    org          = closedPr.organization.login
    repo         = closedPr.repository.name
    merge_action = closedPr.merged
    pr_number    = closedPr.number

    if pr_action == "closed" and merge_action == true
      msgData = {
        channel: "general"
        text: "<#{closedPr.html_url}|##{closedPr.number} _#{closedPr.title}_>
        got merged; checking to see if it created any conflicts…"
        mrkdwn_in: ["text"]
      }
      robot.adapter.customMessage msgData

      postMergeHook = new PostMergeHook(pr_number, org, repo)
      postMergeHook.generateMessage().then (message) =>
        msgData = {
          channel: "general"
          text: message.text
          attachments: message.attachments
        }

        robot.adapter.customMessage msgData

    res.send "OK"
