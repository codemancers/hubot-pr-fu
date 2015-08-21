SINATRA_ENDPOINT = "http://localhost:4567"

module.exports = (robot) ->
  robot.hear /status (\w+)/i, (resp) ->
    command = resp.match[1]

    switch command
      when "all"
        robot.emit "allStats", { room: resp.message.room }
      when "conflicts" || "conflict"
        robot.emit "conflictStats", { room: resp.message.room }
      else
        robot.emit "userStats", { username: command, room: resp.message.room }

  robot.on "allStats", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"
    robot.http("#{SINATRA_ENDPOINT}/all_conflicts").get() (err, res, body) =>
      if err
        robot.send(
          {room: metadata.room},
          "Unable to contact Github API or something went wrong"
        )
      else
        data = JSON.parse(body)
        msgData = {
          channel: metadata.room
          text: data.text
          attachments: data.attachments
        }
        robot.adapter.customMessage msgData


  robot.on "conflictStats", (metadata) ->
    robot.send {room: metadata.room}, "Checking…"
    robot.http("#{SINATRA_ENDPOINT}/all_stats").get() (err, res, body)  =>
      if err
        robot.send(
          {room: metadata.room},
          "Unable to contact Github API or something went wrong"
        )
      else
        data = JSON.parse(body)
        msgData = {
          channel: metadata.room
          text: data.text
        }
        robot.adapter.customMessage msgData

  robot.on "userStats", (metadata) ->
    username = metadata.username

    robot.send {room: metadata.room}, "Checking…"
    robot.http("#{SINATRA_ENDPOINT}/stats/#{username}").get() (err, res, body) =>
      if err
        robot.send(
          {room: metadata.room},
          "Unable to contact Github API or something went wrong"
        )
      else
        data = JSON.parse(body)
        msgData = {
          channel: metadata.room
          text: data.text
          attachments: data.attachments
        }
        robot.adapter.customMessage msgData
