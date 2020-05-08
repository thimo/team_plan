module DashboardsHelper
  def active_members_graph_data
    {
      labels: member_stats.map { |stat| stat[:title] },
      datasets: [
        {
          label: "Actieve leden",
          backgroundColor: "rgba(0, 168, 255, .7)",
          borderColor: "rgba(0, 168, 255, 1)",
          fill: false,
          data: member_stats.map { |stat| stat[:total] }
        }
      ]
    }
  end

  def member_diff_graph_data
    {
      labels: member_stats.map { |stat| stat[:title] },
      datasets: [
        {
          label: "Aanmeldingen",
          backgroundColor: "rgba(70, 195, 95, .7)",
          borderColor: "rgba(70, 195, 95, 1)",
          fill: false,
          data: member_stats.map { |stat| stat[:activated] }
        },
        {
          label: "Afmeldingen",
          backgroundColor: "rgba(250, 66, 74, .7)",
          borderColor: "rgba(250, 66, 74, 1)",
          fill: false,
          data: member_stats.map { |stat| stat[:deactivated] }
        }
      ]
    }
  end

  def member_stats
    @member_stats ||= (0..35).reverse_each.map { |number|
      date = number.months.ago
      {
        title: I18n.l(date, format: :date_long_without_day),
        total: Member.active_for_month(date).size,
        activated: Member.activated_for_month(date).size,
        deactivated: Member.deactivated_for_month(date).size
      }
    }
  end

  def comments_graph_data
    {
      labels: comment_stats.map { |stat| stat[:title] },
      datasets: [
        {
          label: "Algemeen",
          backgroundColor: "rgba(0, 168, 255, .7)",
          borderColor: "rgba(0, 168, 255, 1)",
          data: comment_stats.map { |stat| stat[:generic] }
        },
        {
          label: "Voetbal",
          backgroundColor: "rgba(70, 195, 95, .7)",
          borderColor: "rgba(70, 195, 95, 1)",
          data: comment_stats.map { |stat| stat[:technique] }
        },
        {
          label: "Gedrag",
          backgroundColor: "rgba(250, 66, 74, .7)",
          borderColor: "rgba(250, 66, 74, 1)",
          data: comment_stats.map { |stat| stat[:behaviour] }
        },
        {
          label: "Indeling",
          backgroundColor: "rgba(245, 156, 26, .7)",
          borderColor: "rgba(245, 156, 26, 1)",
          data: comment_stats.map { |stat| stat[:classification] }
        },
        {
          label: "Lidmaatschap",
          backgroundColor: "rgba(137, 148, 160, .7)",
          borderColor: "rgba(137, 148, 160, 1)",
          data: comment_stats.map { |stat| stat[:membership] }
        }
      ]
    }
  end

  def comment_stats
    @comment_stats ||= (0..35).reverse_each.map { |number|
      date = number.months.ago
      {
        title: I18n.l(date, format: :date_long_without_day),
        total: Comment.created_for_month(date).size,
        generic: Comment.created_for_month(date).generic.size,
        technique: Comment.created_for_month(date).technique.size,
        behaviour: Comment.created_for_month(date).behaviour.size,
        classification: Comment.created_for_month(date).classification.size,
        membership: Comment.created_for_month(date).membership.size
      }
    }
  end
end
