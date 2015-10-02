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

  it "processes unmergeable PRs", (done) ->
    nock('statusAll.json', (nockDone) ->
      statusAll = new StatusAll()
      statusAll.allPrs.then (prs) =>
        unMergeablePrs = statusAll.unMergeablePrs(prs)
        expect(unMergeablePrs.length).toEqual(6)
        done()
        this.assertScopesFinished()
        nockDone()
    )

  it "processes unmergeable PRs", (done) ->
    nock('statusAll.json', (nockDone) ->
      statusAll = new StatusAll()
      statusAll.allPrs.then (prs) =>
        usersWhoOpenedPr = [
          'TrevorBramble',
          'sporkmonger',
          'JonRowe',
          'ganmacs',
          'raxoft',
          'dimasusername',
          'gam3',
          'dmathieu',
          'tobiashm',
          'astratto',
          'jeremyevans',
          'rennex',
          'huoxito',
          'apotonick',
          'yegortimoshenko',
          'patriciomacadden',
          'tbuehlmann',
          'rakoo'
        ]
        prsGroupedByUser = statusAll.prsGroupedByUser(prs)
        expect(Object.keys(prsGroupedByUser)).toEqual(usersWhoOpenedPr)
        done()
        this.assertScopesFinished()
        nockDone()
    )
