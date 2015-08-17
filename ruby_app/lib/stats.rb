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
  end

  private

  def stats
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


    aggregator.unmergeable_pulls.each do |pull|
      stats << "#{pull[:number]} #{pull[:title]}\n"
      stats << "Assigned to : #{pull[:assignee]}\n"
      stats << "Opened by   : #{pull[:opened_by]}\n"
      stats << "\n"
    end

    stats
  end
end
