class AllStats
  attr_reader :aggregator

  def initialize(aggregator)
    @aggregator = aggregator
  end

  def to_hash
    if aggregator.open_pulls.count == 0
      { text: "No open PRs :tada:" }
    else
      { text: summary }
    end
  end

  private

  # Returns a string in the following format:
  #
  #  Summary of all open PRs:
  #
  #  11 open PRs
  #
  #  6 by user1
  #  2 by user2
  #  3 by user3
  #
  #  10 mergeable
  #  1 unmergeable
  def summary
    stats = "Summary of all open PRs:\n\n"

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
end
