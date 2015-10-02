jasmine.DEFAULT_TIMEOUT_INTERVAL = 4000
nock = require('nock').back

describe "StatusAll", ->
  StatusAll = require '../scripts/status_all'

  it "should initialize GH information", (done) ->
    nock('statusAll.json', (nockDone) ->
      statusAll = new StatusAll()
      statusAll.allPrs.then (prs) =>
        expect(prs.length).toEqual(19)
        done()
        this.assertScopesFinished()
        nockDone()
    )

  it "processes mergeable PRs", (done) ->
    nock('statusAll.json', (nockDone) ->
      statusAll = new StatusAll()
      statusAll.allPrs.then (prs) =>
        mergeablePrs = statusAll.mergeablePrs(prs)
        expect(mergeablePrs.length).toEqual(13)
        done()
        this.assertScopesFinished()
        nockDone()
    )
