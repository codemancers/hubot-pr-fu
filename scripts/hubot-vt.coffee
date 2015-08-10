module.exports = (robot) ->
  robot.respond /status mine/i, (res) ->
    res.send "Checking with Github…"
    res.send "PR 12345: All good; mergeable to sprint branch\n
      ```
      Send payments to PAPI\n
      from: send-payments-to-papi\n
      to:   sprint\n
      date: 12 Aug 2015\n
      ```"
    res.send "PR 22342: MERGE CONFLICT\n
      ```
      Receive payments from PAPI\n
      from: receive-payments-from-papi\n
      to:   sprint\n
      date: 13 Aug 2015\n\n

      possible conflict in files:\n
     \t 1. app/models/payment.rb\n
     \t Conflict created by PR #12345\n
     \t 2. app/models/papi.rb\n
     \t Conflict created by PR #15616
```"


  # This listeners listens for a POST request with the following params:
  # repo: A string of the form: "username/reponame"w
  # pr: PR number
  robot.router.post '/hubot/gh-hook', (req, res) ->
    robot.send JSON.stringify(req)
    robot.send JSON.stringify(res)
