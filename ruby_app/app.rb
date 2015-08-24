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

get '/merged' do
  content_type "application/json"
  conflict_stats = Aggregator.new.conflict_stats

  if conflict_stats.any_conflicts?
    text = "A PR was merged; it might've created some merge conflicts"
    {
      text: text,
      attachments: conflict_stats.attachments
    }.to_json
  else
    status 302
    {}.to_json
  end
end
