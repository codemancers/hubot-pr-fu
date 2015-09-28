slackToken  = process.env.HUBOT_SLACK_TOKEN
ghAuthToken = process.env.GH_AUTH_TOKEN
ghOrg       = process.env.PR_STATUS_GITHUB_ORG
ghRepo      = process.env.PR_STATUS_GITHUB_REPO

if !(slackToken and ghAuthToken and ghOrg and ghRepo)
  error =
    "\n
    Oops!\n
    The bot needs some environment variables to continue. Please refer to the\n
    README to know how to obtain these variables. The necessary variables are:\n\n

      HUBOT_SLACK_TOKEN\n
      GH_AUTH_TOKEN\n
      PR_STATUS_GITHUB_ORG\n
      PR_STATUS_GITHUB_REPO\n\n

    Exiting now\n
    "

  console.log error
  process.exit(1)

StatusAll       = require("./status_all.coffee")
StatusConflicts = require("./status_conflicts.coffee")
StatusUser      = require("./status_user.coffee")
PostMergeHook   = require("./post_merge_hook.coffee")

module.exports = (robot) ->

  # Matches:
  #
  # @bot status all
  # bot status all
  #
  # Doesn't match:
  #
  # <garbage> @bot status all <garbage>
  # <garbage> bot status all <garbage>
  #
  # <garbage> @bot status all
  # <garbage> bot status all
  #
  # @bot status all <garbage>
  # bot status all <garbage>
  #
  # Test: http://rubular.com/r/ZIZsNV1J6U
  robot.respond /status\u0020(\w+)/, (resp) ->
    command = resp.match[1]

    switch command
      when "all"
        robot.emit "StatusAll", { room: resp.message.room }
      when "conflicts", "conflict"
        robot.emit "StatusConflicts", { room: resp.message.room }
      when "help"
        robot.emit "help", { room: resp.message.room }
      else
        robot.emit "StatusUser", { username: command, room: resp.message.room }

  robot.on "help", (metadata) ->
    message = {
      channel: metadata.room
      text: "Available Commands:"
      attachments: [
        {
          text: "
          `status all`\n\n

          This command returns the PR stats for the repo viz., total open PRs,
          their mergeability status, and links to those PRs.
          ",
          mrkdwn_in: ["text"]
        },
        {
          text: "
          `status conflicts`\n\n

          This command returns all the PRs which have merge conflicts. This has
          more detailed information for those compared to `status all` command.
          The title, PR number, link to that PR, assignee and the username who
          opened this PR is included in the information.
          ",
          mrkdwn_in: ["text"]
        },
        {
          text: "
          `status help`\n\n

          Prints out this help text
          ",
          mrkdwn_in: ["text"]
        },
        {
          text: "
          `status kgrz`\n\n

          This command returns all the PRs opened by this user. This includes
          all open PRs which are mergeable and non-mergeable. The `username` is
          assumed to be a valid Github username. For now, there is no
          authorization or authentication built-in.
          ",
          mrkdwn_in: ["text"]
        }
      ]
    }
    robot.adapter.customMessage message

  robot.on "StatusConflicts", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"

    statusConflicts = new StatusConflicts()
    statusConflicts.generateMessage().then (message) =>
      # Slack ignores empty array for attachments, so this works even if the
      # message doesn't have any attachments
      msgData = {
        channel: metadata.room
        text: message.text
        attachments: message.attachments
      }
      robot.adapter.customMessage msgData

  robot.on "StatusUser", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"

    statusUser = new StatusUser(metadata.username)
    statusUser.generateMessage().then (message) =>
      # Slack ignores empty array for attachments, so this works even if the
      # message doesn't have any attachments
      msgData = {
        channel: metadata.room
        text: message.text
        attachments: message.attachments
      }

      robot.adapter.customMessage msgData

  robot.on "StatusAll", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"

    statusAll = new StatusAll()
    statusAll.generateSummary().then (summary) =>
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

      postMergeHook = new PostMergeHook(pr_number)
      postMergeHook.generateMessage().then (message) =>
        msgData = {
          channel: "general"
          text: message.text
          attachments: message.attachments
        }

        robot.adapter.customMessage msgData

    res.send "OK"
