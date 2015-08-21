require 'octokit'
require './lib/aggregator.rb'
require './lib/all_stats.rb'
require './lib/conflict_stats.rb'
require './lib/user_stats.rb'
require 'json'
require 'sinatra'


Octokit.default_media_type = "application/vnd.github.beta+json"

get '/all_stats' do
  content_type "application/json"

  Aggregator.new.all_stats.to_hash.to_json
end

get '/all_conflicts' do
  content_type "application/json"

  Aggregator.new.conflict_stats.to_hash.to_json
end

get '/stats/:user' do
  content_type "application/json"

  Aggregator.new.user_stats(params[:user]).to_hash.to_json
end
