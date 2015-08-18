SINATRA_ENDPOINT = "http://localhost:4567"

module.exports = (robot) ->
  robot.hear /status conflicts?/i, (resp) ->
    resp.send "Checking…"
    robot.http("#{SINATRA_ENDPOINT}/all_conflicts").get() (err, res, body) =>
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


  robot.hear /status all/i, (resp) ->
    resp.send "Checking…"
    robot.http("#{SINATRA_ENDPOINT}/all_stats").get() (err, res, body)  =>
      if err
        resp.send "Unable to contact Github API or something went wrong"
      else
        data = JSON.parse(body)
        msgData = {
          channel: resp.message.room
          text: data.text
        }
        robot.adapter.customMessage msgData
