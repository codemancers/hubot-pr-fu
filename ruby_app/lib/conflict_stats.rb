class ConflictStats
  attr_reader :aggregator

  def initialize(aggregator)
    @aggregator = aggregator
  end

  def to_hash
    {
      text: "Summary of PRs with conflicts:",
      attachments: attachments
    }
  end

  private

  def attachments
    aggregator.unmergeable_pulls.map do |pull|
      msg_text = ""

      msg_text << "<#{pull[:html_url]}|##{pull[:number]} _#{pull[:title]}_> has a conflict\n"
      msg_text << "\n"
      msg_text << "Assigned to: #{pull[:assignee]}; Opened by: #{pull[:opened_by]}\n"

      {
        text: msg_text,
        color: "#ff0000",
        mrkdwn_in: ["text"]
      }
    end
  end
end
