require 'octokit'
require './lib/aggregator.rb'


Octokit.default_media_type = "application/vnd.github.beta+json"
puts Aggregator.new

# Stats
#
# Mergeable PRs      :  8
# PRs with conflicts :  5
#
# PRs with conflicts:
#
# <number> <title>
# Assigned to: <name>
# Opened by: <name>
