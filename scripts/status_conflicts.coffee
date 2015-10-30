# Description:
#   This module handles the command `status conflicts`. When that command is
#   run, this script would fetch the information of all open PRs from GitHub,
#   and then figure out, based on the key `unmergeable`, if that PR is
#   mergeable or not.
Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'

class StatusConflicts
  constructor: ->
    github = new Octokat(token: process.env.GH_AUTH_TOKEN)

    repo = github.repos(
      process.env.PR_STATUS_GITHUB_ORG,
      process.env.PR_STATUS_GITHUB_REPO
    )

    @allPrs =
      repo.pulls.fetch({status: "open"}).then (prs) =>
        Q.all _.map(prs, (pr) => repo.pulls(pr.number).fetch())

  unMergeablePrs: (prs) ->
    _.filter(prs, (pr) -> pr.mergeable == false)

  generateMessage: ->
    @allPrs.then (prs) =>
      if @unMergeablePrs(prs).length > 0
        attachments = _.map(
          @unMergeablePrs(prs),
          (pr) =>
            assignee = if pr.assignee then pr.assignee.login else "Not assigned"

            stats = ""
            stats += "<#{pr.Links.html.href}|##{pr.number} _#{pr.title}_> has a conflict"
            stats += "\n"
            stats += "Assigned to: #{assignee}; Opened by: #{pr.user.login}\n"

            {
              text: stats
              color: "#ff0000"
              mrkdwn_in: ["text"]
            }
        )

        {
          text:  "Summary of Prs with conflicts:"
          attachments: attachments
        }
      else
        { text: "No unmergeable PRs found :tada:" }

module.exports = StatusConflicts
