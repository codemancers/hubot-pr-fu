class UserStats
  attr_reader :aggregator, :username

  def initialize(aggregator, username)
    @aggregator = aggregator
    @username = username
  end

  def to_hash
    {
      text: "Summary of *#{username}'s* PRs:",
      attachments: attachments,
    }
  end

  private

  def aggregated_data_for_user
    aggregator
      .aggregated_data
      .select { |x| x[:opened_by].downcase == username.downcase }
  end

  def attachments
    aggregated_data_for_user.map do |pull|
      msg_text = ""

      msg_text << "<#{pull[:html_url]}|#{pull[:number]} _#{pull[:title]}_>\n"
      msg_text << "\n"
      if !!pull[:mergeable]
        msg_text << "Assigned to: #{pull[:assignee]} \n"
        msg_color = "#14ff2b"
      else
        msg_text << "Assigned to: #{pull[:assignee]}; Unmergeable \n"
        msg_color = "#ff0000"
      end

      {
        text: msg_text,
        color: msg_color,
        mrkdwn_in: ["text"]
      }
    end
  end
end
