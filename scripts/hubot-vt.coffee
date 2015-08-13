_         = require "underscore"
authToken = process.env.GH_AUTH_TOKEN
ghOrg     = process.env.HUBOT_VT_GITHUB_ORG
ghRepo    = process.env.HUBOT_VT_GITHUB_REPO

module.exports = (robot) ->
  getOpenPrUrls = (prObject) ->
    if prObject.state == "open" then prObject.url else undefined

  robot.hear /status all/i, (resp) ->
    resp.send "Checking…"

    robot
      .http("https://api.github.com/repos/#{ghOrg}/#{ghRepo}/pulls")
      .header('Authorization', "token #{authToken}")
      .get() (err, res, body) =>
        if err
          resp.send "Unable to contact Github API or something went wrong"
        else
          openPrUrls = _.compact(_.map(JSON.parse(body), getOpenPrUrls))
          resp.send "#{_.size(openPrUrls)} PRs in open status"
          resp.send "Now checking for any possible merge conflicts…"
          _.each(
            openPrUrls,
            (openPrUrl) =>
              robot.http(openPrUrl).header('Authorization', "token #{authToken}").get() (err, res, body) =>
                if !err
                  json = JSON.parse(body)

                  if !json.mergeable
                    messageText = "<#{json.html_url}|##{json.number} _#{json.title}_> has a conflict."

                    if json.assignee
                      assignedTo = json.assignee.login
                    else
                      assignedTo = "Not assigned"

                    msgData = {
                      channel: resp.message.room
                      attachments: [
                        text: "
                          #{messageText}\n\n

                          Opened By: #{json.user.login}\n
                          Assigned To: #{assignedTo}
                        "
                        color: "#ff0000"
                        mrkdwn_in: ["text"]
                      ]
                    }
                    robot.adapter.customMessage msgData
          )
