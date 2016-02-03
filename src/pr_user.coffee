# Description:
#   This script caters to the command `pr orgname/repo <username>`. The
#   username is expected to be a GitHub username. There are currently no
#   checks to see if that user belongs to the organization, or even if the
#   user exists. Another assumption is that the usernames are
#   case-insensitive. That is, `kgrz` and `Kgrz` are the same user.
Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'

class PrUser
  constructor: (@username, @org, @repo) ->
    github    = new Octokat(token: process.env.GH_AUTH_TOKEN)

    repo = github.repos(@org, @repo)

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
      prsByUser = @prsByUser(prs)

      if prsByUser.length > 0
        attachments = _.map(
          prsByUser,
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

module.exports = PrUser
