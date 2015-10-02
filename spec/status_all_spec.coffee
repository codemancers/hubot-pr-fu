jasmine.DEFAULT_TIMEOUT_INTERVAL=100000
describe "StatusAll", ->
  StatusAll = require '../scripts/status_all'

  it "should initialize GH information", (done) ->
    statusAll = new StatusAll()

    statusAll.allPrs.then (prs) ->
      expect(prs.length).toEqual(8)
      done()
