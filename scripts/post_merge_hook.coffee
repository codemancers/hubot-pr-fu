Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'
StatusConflicts = require './status_conflicts'

class PostMergeHook
  constructor: (@prNumber) ->
    github    = new Octokat(token: process.env.GH_AUTH_TOKEN)

    @repo = github.repos(
      process.env.PR_STATUS_GITHUB_ORG,
      process.env.PR_STATUS_GITHUB_REPO
    )

    @allPrs =
      repo.pulls.fetch({status: "open"}).then (prs) ->
        Q.all _.map(prs, (pr) -> repo.pulls(pr.number).fetch())

  unMergeablePrs: (prs) ->
    _.filter(prs, (pr) -> pr.mergeable == false)

  getClosedPrDetails: ->
    @repo.pulls(@prNumber).fetch()

  generateMessage: ->
    conflictsMessage = new StatusConflicts().generateMessage()

    Q.allSettled([@getClosedPrDetails(), @allPrs, conflictsMessage])
     .then (results) =>
       closedPr = results[0].value
       allPrs   = results[1].value
       message  = results[2].value

       if @unMergeablePrs(allPrs).length
         text = "
           There are merge conflicts. Run `@bot status conflicts` for more info
           "
         {
           text: text
           attachments: message.attachments
         }
       else
         {
           text: "No conflicts 👍🏽"
         }

module.exports = PostMergeHook
