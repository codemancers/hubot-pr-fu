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

  robot.on "conflictStats", (metadata) ->
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


  robot.on "allStats", (metadata) ->
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

  robot.router.post '/hubot/hook', (req, res) ->
    data   = if req.body.payload? then JSON.parse req.body.payload else req.body
    # This is either `opened` or `closed`. We'd need to check the merge status
    # everytime a PR is closed and merged. The `merged` key gives us the second
    # piece of information.
    pr_action    = data.action
    merge_action = data.pull_request.merged
    pr_number    = data.pull_request.number

    if pr_action == "closed" and merge_action == true
      robot.http("#{SINATRA_ENDPOINT}/merged").get() (err, resp, body) =>
        if err
          robot.send(
            {room: "general"},
            "Unable to contact Github API or something went wrong"
          )
        else
          # If there are no conflicts, don't do anything
          if resp.statusCode != 302
            data = JSON.parse(body)
            msgData = {
              channel: "general"
              text: data.text
              attachments: data.attachments
            }

            robot.adapter.customMessage msgData

    res.send "OK"
