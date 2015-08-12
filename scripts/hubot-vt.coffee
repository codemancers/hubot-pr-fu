_ = require('underscore')

module.exports = (robot) ->

  allOpenPrsBy = (ghUsername) ->
    allPrsByCurrentUserStr = robot.brain.get "gh-prs-opened-by-#{ghUserName}"

    if allPrsByCurrentUserStr
      allPrsByCurrentUser = JSON.parse(allPrsByCurrentUserStr)
    else
      allPrsByCurrentUser = []

    return allPrsByCurrentUser

  allOpenPrs = () ->
    allOpenPrsStr = robot.brain.get "open-prs"

    if allOpenPrsStr
      allOpenPrs = JSON.parse(allOpenPrsStr)
    else
      allOpenPrs = []

    return allOpenPrs

  robot.respond /status mine/i, (res) ->
    # Check if the github id for this user exists.
    # If not, ask for github user name
    slackUser = res.envelope.user.name
    ghUserName = robot.brain.get "gh-username-for-#{slackUser}"

    if !ghUserName
      res.send "I don't know your username. Care to tell me?"
      robot.respond /(\w+)/i, (resp) ->
        givenUserName = resp.match[1]
        robot.http("https://api.github.com/users/#{resp}").get() (err, res, body) ->
          if err
            res.send "Unable to check with Github right now"
            return
          else
            console.log "here"
            robot.brain.set "gh-username-for-#{slackUser}", givenUserName
            resp.send "Ah, got it"
            return
    else
      res.send "Checking with Github…"
      robot.emit "check_open_prs", {
        slackUserName: slackUser,
        ghUserName: ghUserName
      }


  robot.on "check_open_prs", (userMetaData) ->
    slackUserName = userMetaData.slackUserName
    ghUserName =  userMetaData.ghUserName

    robot.http("https://api.github.com/repos/veritrans/turbo/pulls/")

  robot.on "pr_opened", (data) ->
    allOpenPrsByCurrentUser = _.merge(allOpenPrsBy(data.ghUserName), [ data.prId ])
    allOpenPrs = _.merge(allOpenPrs(), [ data.prId ])

    robot.brain.set(
      "gh-prs-opened-by-#{data.ghUserName}",
      JSON.stringify(allOpenPrsByCurrentUser)
    )
    robot.brain.set("open-prs", JSON.stringify(allOpenPrs))

  robot.on "pr_closed", (data) ->
    allOpenPrsByCurrentUser = _.without(allOpenPrsBy(data.ghUserName), data.prId)
    allOpenPrs = _.without(allOpenPrs(), data.prId)

    robot.brain.set(
      "gh-prs-opened-by-#{data.ghUserName}",
      JSON.stringify(allPrsByCurrentUser)
    )
    robot.brain.set("open-prs", JSON.stringify(allOpenPrs))

  robot.router.post '/hubot/gh-hook', (req, res) ->
    repoName = req.body.repository.full_name
    pusher   = req.body.sender.login

    message = switch req.headers['x-github-event']
      when 'push'
        "#{pusher} has pushed a branch to #{repoName}"
        robot.send { room: 'general' }, message
      when 'commit'
        "#{pusher} has committed something to #{repoName}"
        robot.send { room: 'general' }, message
      when 'pull_request'
        action = req.body.action
        prId   = req.body.pull_request.number
        ghUserName = req.body.user.login

        switch action
          when "opened"
            robot.emit "pr_opened", {
              prId: prId,
              ghUserName: req.body.user.login
            }
          when "closed"
            robot.emit "pr_opened", {
              prId: prId,
              ghUserName: req.body.user.login
            }

        robot.send { room: 'general' },


    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
