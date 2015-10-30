nock = require('nock').back

describe "PrAll", ->
  PrAll = require '../scripts/pr_all'

  it "should initialize GH information", (done) ->
    nock('prAll.json', (nockDone) ->
      prAll = new PrAll()
      prAll.allPrs.then (prs) =>
        expect(prs.length).toEqual(19)
        done()
        this.assertScopesFinished()
        nockDone()
    )

  it "processes mergeable PRs", (done) ->
    nock('prAll.json', (nockDone) ->
      prAll = new PrAll()
      prAll.allPrs.then (prs) =>
        mergeablePrs = prAll.mergeablePrs(prs)
        expect(mergeablePrs.length).toEqual(13)
        done()
        this.assertScopesFinished()
        nockDone()
    )

  it "processes mergeable PRs", (done) ->
    nock('prAll.json', (nockDone) ->
      prAll = new PrAll()
      prAll.allPrs.then (prs) =>
        mergeablePrs = prAll.mergeablePrs(prs)
        expect(mergeablePrs.length).toEqual(13)
        done()
        this.assertScopesFinished()
        nockDone()
    )

  it "processes unmergeable PRs", (done) ->
    nock('prAll.json', (nockDone) ->
      prAll = new PrAll()
      prAll.allPrs.then (prs) =>
        unMergeablePrs = prAll.unMergeablePrs(prs)
        expect(unMergeablePrs.length).toEqual(6)
        done()
        this.assertScopesFinished()
        nockDone()
    )

  it "processes unmergeable PRs", (done) ->
    nock('prAll.json', (nockDone) ->
      prAll = new PrAll()
      prAll.allPrs.then (prs) =>
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
        prsGroupedByUser = prAll.prsGroupedByUser(prs)
        expect(Object.keys(prsGroupedByUser)).toEqual(usersWhoOpenedPr)
        done()
        this.assertScopesFinished()
        nockDone()
    )

  it "generates summary message", (done) ->
    nock('prAll.json', (nockDone) ->
      prAll = new PrAll()
      prAll.generateSummary().then (message) =>
        messageExpected = "
          Summary of all open PRs\n\n

          19 open PRs\n\n

          1 by TrevorBramble: <https://github.com/sinatra/sinatra/pull/1033|#1033>\n
          1 by sporkmonger: <https://github.com/sinatra/sinatra/pull/1026|#1026>\n
          1 by JonRowe: <https://github.com/sinatra/sinatra/pull/1025|#1025>\n
          1 by ganmacs: <https://github.com/sinatra/sinatra/pull/1024|#1024>\n
          1 by raxoft: <https://github.com/sinatra/sinatra/pull/1021|#1021>\n
          1 by dimasusername: <https://github.com/sinatra/sinatra/pull/1019|#1019>\n
          1 by gam3: <https://github.com/sinatra/sinatra/pull/1006|#1006>\n
          1 by dmathieu: <https://github.com/sinatra/sinatra/pull/984|#984>\n
          1 by tobiashm: <https://github.com/sinatra/sinatra/pull/968|#968>\n
          1 by astratto: <https://github.com/sinatra/sinatra/pull/942|#942>\n
          2 by jeremyevans: <https://github.com/sinatra/sinatra/pull/896|#896>, <https://github.com/sinatra/sinatra/pull/895|#895>\n
          1 by rennex: <https://github.com/sinatra/sinatra/pull/889|#889>\n
          1 by huoxito: <https://github.com/sinatra/sinatra/pull/884|#884>\n
          1 by apotonick: <https://github.com/sinatra/sinatra/pull/840|#840>\n
          1 by yegortimoshenko: <https://github.com/sinatra/sinatra/pull/803|#803>\n
          1 by patriciomacadden: <https://github.com/sinatra/sinatra/pull/793|#793>\n
          1 by tbuehlmann: <https://github.com/sinatra/sinatra/pull/774|#774>\n
          1 by rakoo: <https://github.com/sinatra/sinatra/pull/714|#714>\n\n

          13 mergeable\n
          6 unmergeable\n\n

          Run `@bot pr conflicts` to know details about unmergeable pulls\n
        ".replace(/^\ /gm, "")
        expect(message).toEqual(messageExpected)
        done()
        this.assertScopesFinished()
        nockDone()
    )
