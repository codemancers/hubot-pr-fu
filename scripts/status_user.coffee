Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'

class StatusUser
  constructor: (@username) ->
    github    = new Octokat(token: process.env.GH_AUTH_TOKEN)

    repo = github.repos(
      process.env.PR_STATUS_GITHUB_ORG,
      process.env.PR_STATUS_GITHUB_REPO
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

  prsAssignedToUser: (prs) ->
    _.filter(
      prs,
      (pr) =>
        pr.assignee &&
        (pr.assignee.login.toLowerCase() == @username.toLowerCase())
    )

  generateAssignedPrsMessage: (prs) ->
    prsAssignedToUser  = @prsAssignedToUser(prs)

    if prsAssignedToUser.length > 0
      attachments = _.map(
        prsAssignedToUser,
        (pr) =>
          assignedBy = pr.user.login

          stats = ""
          stats += "<#{pr.Links.html.href}|##{pr.number} _#{pr.title}_>"
          stats += "\n"

          if pr.mergeable == true
            stats += "Assigned by: #{assignedBy}\n"
            msgColor = "#14ff2b"
          else
            stats += "Assigned by: #{assignedBy}; Unmergeable\n"
            msgColor = "#ff0000"

          {
            text: stats
            color: msgColor
            mrkdwn_in: ["text"]
          }
      )

      {
        text: "Summary of PRs assigned to *#{@username}*:"
        attachments: attachments
      }
    else
      { text: "No pending PRs to be reviewed :clap:"}

  generateOwnedPrsMessage: (prs)->
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
        text: "Summary of PRs opened by *#{@username}*:"
        attachments: attachments
      }
    else
      { text: "No pending PRs for #{@username} :clap:"}


  generateMessage: ->
    @allPrs.then (prs) =>
      {
        assignedPrMessage: @generateAssignedPrsMessage(prs)
        ownedPrMessage: @generateOwnedPrsMessage(prs)
      }

module.exports = StatusUser
