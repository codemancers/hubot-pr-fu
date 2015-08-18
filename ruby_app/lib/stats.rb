# This class takes care of formatting the aggregated data in the format that
# slack requires. The to_hash method can be used to get a hash that can then be
# converted to JSON in the format that the slack bot expects. This will ensure
# that all the aggregation and JSON manipulation is done on Ruby.
class Stats
  attr_reader :aggregator

  def initialize(aggregator)
    @aggregator = aggregator
  end

  def to_s
    stats
  end

  def to_hash
    attachments =
      aggregator.unmergeable_pulls.map do |pull|
        msg_text = ""

        msg_text << "<#{pull[:html_url]}|#{pull[:number]} _#{pull[:title]}_> has a conflict\n"
        msg_text << "\n"
        msg_text << "Assigned to: #{pull[:assignee]}; Opened by:#{pull[:opened_by]}\n"

        {
          text: msg_text,
          color: "#ff0000",
          mrkdwn_in: ["text"]
        }
      end

    {
      text: basic_stats,
      attachments: attachments
    }
  end

  private

  # Outputs:
  #
  #  11 open PRs
  #
  #  6 by user1
  #  2 by user2
  #  3 by user3
  #
  #  10 mergeable
  #  1 unmergeable
  def basic_stats
    stats = ""

    stats << "#{aggregator.open_pulls.count} open PRs\n"
    stats << "\n"

    aggregator.aggregated_data.group_by { |x| x[:opened_by] }.each do |k, v|
      stats << "#{v.count} by #{k}\n"
    end

    stats << "\n"
    stats << "#{aggregator.mergeable_pulls.count} mergeable\n"
    stats << "#{aggregator.unmergeable_pulls.count} unmergeable\n"
    stats << "\n"

    stats
  end

  # Outputs:
  #
  #  11 open PRs
  #
  #  6 by user1
  #  2 by user2
  #  3 by user3
  #
  #  10 mergeable
  #  1 unmergeable
  #
  #  123 title
  #  Assigned to: <userx>
  #  Opened by: <usery>
  def stats
    stats = basic_stats

    aggregator.unmergeable_pulls.each do |pull|
      stats << "#{pull[:number]} #{pull[:title]}\n"
      stats << "Assigned to : #{pull[:assignee]}\n"
      stats << "Opened by   : #{pull[:opened_by]}\n"
      stats << "\n"
    end

    stats
  end
end
