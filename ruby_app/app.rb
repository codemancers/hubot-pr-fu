require 'octokit'
require './lib/aggregator.rb'
require './lib/stats.rb'
require 'json'
require 'sinatra'


Octokit.default_media_type = "application/vnd.github.beta+json"

get '/all_stats' do
  content_type "application/json"

  Aggregator.new.stats.to_hash.to_json
end

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
