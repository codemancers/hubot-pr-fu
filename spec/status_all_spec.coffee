describe "StatusAll", ->
  StatusAll = require '../scripts/status_all'

  it "should initialize GH information", (done) ->
    statusAll = new StatusAll()

    statusAll.allPrs.then (prs) ->
      expect(prs).to.be.an.Array
      done()
