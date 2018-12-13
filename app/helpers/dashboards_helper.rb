# frozen_string_literal: true

module DashboardsHelper
  def dashboard_members_graph_data
    member_stats = (0..23).reverse_each.map do |number|
      date = number.months.ago
      debugger
      {
        title: I18n.l(date, format: :date_long_without_day),
        total: Member.active_for_month(date).size,
        activated: Member.activated_for_month(date).size,
        deactivated: Member.deactivated_for_month(date).size
      }
    end

    {
      labels: member_stats.map { |stat| stat[:title] },
      datasets: [
        {
          label: "Totaal",
          backgroundColor: "rgba(0, 168, 255, .7)",
          borderColor: "rgba(0, 168, 255, 1)",
          lineTension: 0.3,
          fill: false,
          data: member_stats.map { |stat| stat[:total] }
        },
        {
          label: "Aanmeldingen",
          backgroundColor: "rgba(70, 195, 95, .7)",
          borderColor: "rgba(70, 195, 95, 1)",
          lineTension: 0.3,
          fill: false,
          data: member_stats.map { |stat| stat[:activated] }
        },
        {
          label: "Afmeldingen",
          backgroundColor: "rgba(250, 66, 74, .7)",
          borderColor: "rgba(250, 66, 74, 1)",
          lineTension: 0.3,
          fill: false,
          data: member_stats.map { |stat| stat[:deactivated] }
        }
      ]
    }
  end
end
