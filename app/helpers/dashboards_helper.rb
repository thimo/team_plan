# frozen_string_literal: true

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
    @member_stats ||= (0..23).reverse_each.map do |number|
      date = number.months.ago
      {
        title: I18n.l(date, format: :date_long_without_day),
        total: Member.active_for_month(date).size,
        activated: Member.activated_for_month(date).size,
        deactivated: Member.deactivated_for_month(date).size
      }
    end
  end
end
