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

get '/merged/:pr_number' do
  content_type "application/json"

  pr_number = params[:pr_number].to_i
  aggregator = Aggregator.new
  closed_pr = aggregator.repo.rels[:pulls].get(number: pr_number).data.first

  conflict_stats = aggregator.conflict_stats

  if conflict_stats.any_conflicts?
    text = "<#{closed_pr[:html_url]}|##{closed_pr[:number]} _#{closed_pr[:title].gsub(/\.$/, '')}_>
    was merged; it might've created some merge conflicts"
    {
      text: text,
      attachments: conflict_stats.attachments
    }.to_json
  else
    status 302
    {}.to_json
  end
end
