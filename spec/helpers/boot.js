nock = require('nock').back
nock.fixtures = __dirname + '/../fixtures'
nock.setMode('record')

jasmine.DEFAULT_TIMEOUT_INTERVAL = 100000;
require('coffee-script/register');
