# frozen_string_literal: true

module Admin
  class AnalyticsController < BaseController
    def index
      run :admin_analytics_index, { current_user: Current.user, alcaldia_id: params[:alcaldia_id], state_id: params[:state_id], tab: params[:tab], date_from: params[:date_from], date_to: params[:date_to] },
          success: ->(result) {
            @alcaldias = result.value[:alcaldias]
            @states = result.value[:states]
            @tab = result.value[:tab]
            assign_tab_data(result.value)
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end

    private

    def assign_tab_data(data)
      case @tab
      when "team"
        @resolution_rate = data[:resolution_rate]
        @stage_times = data[:stage_times]
        @official_load = data[:official_load]
        @official_reopens = data[:official_reopens]
        @year_over_year = data[:year_over_year]
      when "trends"
        @by_dow = data[:by_dow]
        @by_hour = data[:by_hour]
        @monthly_comparison = data[:monthly_comparison]
        @problem_categories = data[:problem_categories]
        @top_locations = data[:top_locations]
      when "sla"
        @sla_by_category = data[:sla_by_category]
        @sla_by_official = data[:sla_by_official]
        @sla_trend = data[:sla_trend]
        @red_flags = data[:red_flags]
      when "satisfaction"
        @total_resolved = data[:total_resolved]
        @accepted_count = data[:accepted_count]
        @rejected_count = data[:rejected_count]
        @no_response_count = data[:no_response_count]
        @acceptance_by_category = data[:acceptance_by_category]
        @inactive_reports = data[:inactive_reports]
      when "zonas"
        @top_locations = data[:top_locations]
        @report_by_zone = data[:report_by_zone]
      end
    end
  end
end
