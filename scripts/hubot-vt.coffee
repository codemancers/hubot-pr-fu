module.exports = (robot) ->
  getOpenPrUrls = (prObject) ->
    if prObject.state == "open" then prObject.url else undefined

  robot.hear /status all/i, (resp) ->
    resp.send "Checking..."
    robot.http("http://localhost:4567/all_stats").get() (err, res, body)  =>
      if err
        resp.send "Unable to contact Github API or something went wrong"
      else
        data = JSON.parse(body)
        msgData = {
          channel: resp.message.room
          text: data.text
          attachments: data.attachments
        }
        robot.adapter.customMessage msgData
