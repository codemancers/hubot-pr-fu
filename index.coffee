fs = require 'fs'
path = require 'path'
Octokat = require 'octokat'
_       = require 'underscore'
Q       = require 'q'

module.exports = (robot, scripts) ->
  scriptsPath = path.resolve(__dirname, 'scripts')
  fs.exists scriptsPath, (exists) ->
    if exists
      for script in fs.readdirSync(scriptsPath)
        if scripts? and '*' not in scripts
          robot.loadFile(scriptsPath, script) if script in scripts
        else
          robot.loadFile(scriptsPath, script)
