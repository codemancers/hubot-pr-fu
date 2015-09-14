Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'

class StatusAll
  # For some reason, calling @fetchAllPrs() in the constructor doesn't seem to
  # work, where fetchAllPrs()'s functionality is to populate the @allPrs
  # variable
  constructor: ->
    github = new Octokat(token: process.env.GH_AUTH_TOKEN)

    repo = github.repos(
      process.env.HUBOT_VT_GITHUB_ORG,
      process.env.HUBOT_VT_GITHUB_REPO
    )

    @allPrs =
      repo.pulls.fetch({status: "open"}).then (prs) =>
        Q.all _.map(prs, (pr) => repo.pulls(pr.number).fetch())

  mergeablePrs: (prs) ->
    _.filter(prs, (pr) -> pr.mergeable == true)

  unMergeablePrs: (prs) ->
    _.filter(prs, (pr) -> pr.mergeable == false)

  prsGroupedByUser: (prs) ->
    _.groupBy(prs, (pr) -> pr.user.login)

  # Returns a string in the following format:
  #
  #  Summary of all open PRs:
  #
  #  11 open PRs
  #
  #  6 by user1
  #  2 by user2
  #  3 by user3
  #
  #  10 mergeable
  #  1 unmergeable
  #
  #  Run `status conflicts` to know details about unmergeable pulls
  generateSummary: ->
    @allPrs.then (prs) =>
      if prs.length > 0
        mergeablePrCount   = @mergeablePrs(prs).length
        unMergeablePrCount = @unMergeablePrs(prs).length

        stats = "Summary of all open PRs\n\n"
        stats += "#{prs.length} open PRs\n"
        stats += "\n"

        _.each(
          @prsGroupedByUser(prs),
          (prs, user) =>
            linksToPrs = _.map(
              prs,
              (pr) -> "<#{pr.Links.html.href}|##{pr.number}>"
            )
            stats += "#{prs.length} by #{user}: #{linksToPrs.join(", ")}\n"
        )

        stats += "\n"
        stats += "#{mergeablePrCount} mergeable\n"
        stats += "#{unMergeablePrCount} unmergeable\n"
        stats += "\n"
        stats += "Run `status conflicts` to know details about unmergeable pulls"
        stats += "\n"
      else
        stats = "No open PRs :tada:"

module.exports = StatusAll
