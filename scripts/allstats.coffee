Github   = require 'github-api'
_        = require 'underscore'

class AllStats
  constructor: ->
    @github = new Github({
      token: process.env.GH_AUTH_TOKEN,
      auth: 'oauth'
    })

    @repo = @github.getRepo(
      process.env.HUBOT_VT_GITHUB_ORG,
        process.env.HUBOT_VT_GITHUB_REPO
    )

  generateSummary: (fn) ->
    @repo.listPulls(
      "open",
      (err, pullRequests) ->
        stats = "Summary of all open PRs\n\n"
        stats += "#{pullRequests.length} open PRs\n"
        stats += "\n"

        prsGroupedByUser =
          _.groupBy(pullRequests, (prHash) -> prHash.user.login)

        _.each(
          prsGroupedByUser,
          (prs, user) =>
            linksToPrs = _.map(prs, (pr) -> "<#{pr.html_url}|##{pr.number}>")
            stats += "#{prs.length} by #{user}: #{linksToPrs.join(", ")}"
        )

        mergeablePulls =
          _.filter(pullRequests, (pr) -> pr.mergeable == true )

        unmergeablePulls =
          _.filter(pullRequests, (pr) -> pr.mergeable == false )

        stats += "\n"
        stats += "#{mergeablePulls.length} mergeable\n"
        stats += "#{unmergeablePulls.length} unmergeable\n"
        stats += "\n"
        stats += "Run `status conflicts` to know details about unmergeable pulls"
        stats += "\n"
        fn(stats)
    )



module.exports = AllStats
