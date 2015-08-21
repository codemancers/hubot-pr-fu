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

  robot.hear /status (\w+)/i, (resp) ->
    username = resp.match[1]

    # These cases are already covered by the other commands. Ugly way, but this
    # will do for now
    if username == "all" || username == "conflicts" || username == "conflict"
      return

    resp.send "Checking…"

    robot.http("#{SINATRA_ENDPOINT}/stats/#{username}").get() (err, res, body) =>
      data = JSON.parse(body)
      msgData = {
        channel: resp.message.room
        text: data.text
        attachments: data.attachments
      }
      robot.adapter.customMessage msgData
