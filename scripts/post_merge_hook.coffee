Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'
StatusConflicts = require './status_conflicts'

class PostMergeHook
  constructor: (@prNumber) ->
    github    = new Octokat(token: process.env.GH_AUTH_TOKEN)

    @repo = github.repos(
      process.env.HUBOT_VT_GITHUB_ORG,
      process.env.HUBOT_VT_GITHUB_REPO
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
           <#{closedPr.Links.html.href}|##{closedPr.number} _#{closedPr.title}_>
           was merged; it might've created some merge conflicts
         "

         {
           text: text
           attachments: message.attachments
         }
       else
         {
           text: "A PR was closed; didn't create any conflicts 👍🏽"
         }

module.exports = PostMergeHook
