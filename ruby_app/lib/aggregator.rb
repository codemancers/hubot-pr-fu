class Aggregator
  attr_reader :client, :repo, :pulls, :aggregated_data, :pull_data

  GH_AUTH_TOKEN        = ENV["GH_AUTH_TOKEN"]
  HUBOT_VT_GITHUB_ORG  = ENV["HUBOT_VT_GITHUB_ORG"]
  HUBOT_VT_GITHUB_REPO = ENV["HUBOT_VT_GITHUB_REPO"]

  def initialize
    @client = Octokit::Client.new access_token: GH_AUTH_TOKEN
    @repo   = client.repo "#{HUBOT_VT_GITHUB_ORG}/#{HUBOT_VT_GITHUB_REPO}"

    get_pulls!
    get_individual_open_pull_data!
  end

  def open_pulls
    pulls.select { |x| x[:state] = "open" }
  end

  def mergeable_pulls
    aggregated_data.select { |x| x[:mergeable] == true }
  end

  def unmergeable_pulls
    aggregated_data.select { |x| x[:mergeable] != true }
  end

  def aggregated_data
    @aggregated_data ||=
      pull_data.map do |pull|
        {
          title:      pull[:title],
          mergeable:  pull[:mergeable] || "Unspecified",
          assignee:   pull[:assignee] || "Not assigned",
          number:     pull[:number],
          opened_by:  pull[:user][:login],
          html_url:   pull[:html_url],
          created_at: pull[:created_at]
        }
      end
  end

  def to_s
    Stats.new(self).to_s
  end

  private

  def get_pulls!
    @pulls ||= repo.rels[:pulls].get.data
  end

  def get_individual_open_pull_data!
    @pull_data ||=
      open_pulls.map do |pull|
        pull.rels[:self].get.data
      end
  end
end
