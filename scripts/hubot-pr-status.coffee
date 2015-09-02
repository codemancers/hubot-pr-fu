SINATRA_ENDPOINT = "http://localhost:4567"
BOT_NAME = process.env.HUBOT_SLACK_BOT_NAME

module.exports = (robot) ->
  # Matches:
  #
  # @bot status all
  # bot status all
  # status all
  #
  # Doesn't match:
  #
  # <garbage> @bot status all <garbage>
  # <garbage> bot status all <garbage>
  # <garbage> status all <garbage>
  #
  # <garbage> @bot status all
  # <garbage> bot status all
  # <garbage> status all
  #
  # @bot status all <garbage>
  # bot status all <garbage>
  # status all <garbage>
  #
  # Test: http://rubular.com/r/ZIZsNV1J6U
  robot.hear ///^(?:#{BOT_NAME}\u0020|@#{BOT_NAME}\u0020)?status\u0020(\w+)$///, (resp) ->
    command = resp.match[1]

    switch command
      when "all"
        robot.emit "allStats", { room: resp.message.room }
      when "conflicts" || "conflict"
        robot.emit "conflictStats", { room: resp.message.room }
      when "help"
        robot.emit "help", { room: resp.message.room }
      else
        robot.emit "userStats", { username: command, room: resp.message.room }

  robot.on "help", (metadata) ->
    message = {
      channel: metadata.room
      text: "Available Commands:"
      attachments: [
        {
          text: "
          `status all`\n\n

          This command returns the PR stats for the repo viz., total open PRs,
          their mergeability status, and links to those PRs.
          ",
          mrkdwn_in: ["text"]
        },
        {
          text: "
          `status conflicts`\n\n

          This command returns all the PRs which have merge conflicts. This has
          more detailed information for those compared to `status all` command.
          The title, PR number, link to that PR, assignee and the username who
          opened this PR is included in the information.
          ",
          mrkdwn_in: ["text"]
        },
        {
          text: "
          `status help`\n\n

          Prints out this help text
          ",
          mrkdwn_in: ["text"]
        },
        {
          text: "
          `status kgrz`\n\n

          This command returns all the PRs opened by this user. This includes
          all open PRs which are mergeable and non-mergeable. The `username` is
          assumed to be a valid Github username. For now, there is no
          authorization or authentication built-in.
          ",
          mrkdwn_in: ["text"]
        }
      ]
    }
    robot.adapter.customMessage message

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
      robot.http("#{SINATRA_ENDPOINT}/merged/#{pr_number}").get() (err, resp, body) =>
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
