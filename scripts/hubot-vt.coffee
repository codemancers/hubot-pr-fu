module.exports = (robot) ->
  robot.respond /status mine/i, (res) ->
    res.send "Checking with Github…"
    setTimeout(->
      res.send "Here is a summary of all your prs:\n
        \n
          ```
PR 12345: All good; mergeable to sprint branch\n
     \t Send payments to PAPI\n
     \t from: send-payments-to-papi\n
     \t to:   sprint\n
     \t date: 12 Aug 2015\n
     \n\n\n
PR 22342: MERGE CONFLICT\n
     \t Receive payments from PAPI\n
     \t from: receive-payments-from-papi\n
     \t to:   sprint\n
     \t date: 13 Aug 2015\n
     \n
     \t possible conflict in files:\n
     \t\t 1. app/models/payment.rb\n
     \t\t Conflict created by PR #12345\n
     \t\t 2. app/models/papi.rb\n
     \t\t Conflict created by PR #15616
```"
    , 2000)
