_ = require "underscore"
authToken = process.env.GH_AUTH_TOKEN

module.exports = (robot) ->

  getOpenPrUrls = (prObject) ->
    if prObject.state == "open" then prObject.url else undefined

  robot.respond /status/i, (resp) ->
    resp.send "Checking…"

    robot
      .http("https://api.github.com/repos/sinatra/sinatra/pulls")
      .header('Authorization', "token #{authToken}")
      .get() (err, res, body) =>
        if err
          resp.send "Unable to contact Github API or something went wrong"
        else
          openPrUrls = _.compact(_.map(JSON.parse(body), getOpenPrUrls))
          resp.send "#{_.size(openPrUrls)} PRs in open status"
          _.map(
            openPrUrls,
            (openPrUrl) =>
              robot.http(openPrUrl).header('Authorization', "token #{authToken}").get() (err, res, body) =>
                if !err
                  json = JSON.parse(body)
                  if json.mergeable
                    resp.send "PR #{openPrUrl} is mergeable"
                  else
                    resp.send "PR #{openPrUrl} is NOT mergeable"
          )
