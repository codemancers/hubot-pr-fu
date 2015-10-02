nock = require('nock').back
describe "StatusAll", ->
  StatusAll = require '../scripts/status_all'

  it "should initialize GH information", (done) ->
    nock('statusAll.json', (nockDone) ->
      statusAll = new StatusAll()

      statusAll.allPrs.then (prs) =>
        expect(prs.length).toEqual(19)
        this.assertScopesFinished()
        nockDone()
        done()
    )
