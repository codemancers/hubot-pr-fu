Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'

class StatusUser
  constructor: (@username) ->
    github    = new Octokat(token: process.env.GH_AUTH_TOKEN)

    repo = github.repos(
      process.env.HUBOT_VT_GITHUB_ORG,
      process.env.HUBOT_VT_GITHUB_REPO
    )

    @allPrs =
      repo.pulls.fetch({status: "open"}).then (prs) =>
        Q.all _.map(prs, (pr) => repo.pulls(pr.number).fetch())

  # Should we instead use toLocaleLowerCase()?
  prsByUser: (prs) ->
    _.filter(
      prs,
      (pr) =>
        pr.user.login.toLowerCase() == @username.toLowerCase()
    )

  generateMessage: ->
    @allPrs.then (prs) =>

      if @prsByUser(prs) > 0
        attachments = _.map(
          @prsByUser(prs),
          (pr) =>
            assignee = if pr.assignee then pr.assignee.login else "Not assigned"

            stats = ""
            stats += "<#{pr.Links.html.href}|##{pr.number} _#{pr.title}_>"
            stats += "\n"

            if pr.mergeable == true
              stats += "Assigned to: #{assignee}\n"
              msgColor = "#14ff2b"
            else
              stats += "Assigned to: #{assignee}; Unmergeable\n"
              msgColor = "#ff0000"

            {
              text: stats
              color: msgColor
              mrkdwn_in: ["text"]
            }
        )

        {
          text: "Summary of *#{@username}'s'* PRs:"
          attachments: attachments
        }
      else
        { text: "No pending PRs for #{@username} :clap:"}

module.exports = StatusUser
