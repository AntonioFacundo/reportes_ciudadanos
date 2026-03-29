# frozen_string_literal: true

module Admin
  class AnalyticsIndex < RageArch::UseCase::Base
    use_case_symbol :admin_analytics_index
    deps :analytics_repo, :alcaldia_repo, :state_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      base_ids = user.alcaldia_ids_for_admin || []
      all_ids = base_ids.presence || Alcaldia.pluck(:id)

      if params[:state_id].present?
        all_ids = Alcaldia.where(id: all_ids).where(state_id: params[:state_id]).pluck(:id)
      end

      alcaldias = alcaldia_repo.list_by_ids_and_state(all_ids, state_id: params[:state_id])
      states = state_repo.list_ordered

      aid = params[:alcaldia_id].presence
      date_from = params[:date_from].presence
      date_to = params[:date_to].presence
      reports = analytics_repo.scoped_reports(alcaldia_id: aid, base_ids: all_ids, date_from: date_from, date_to: date_to)

      tab = params[:tab].presence || "team"
      tab_data = case tab
      when "team"
        {
          resolution_rate: analytics_repo.resolution_rate(reports, date_from: date_from, date_to: date_to),
          stage_times: analytics_repo.stage_times(reports, date_from: date_from, date_to: date_to),
          official_load: analytics_repo.official_load(alcaldia_id: aid),
          official_reopens: analytics_repo.official_reopens(alcaldia_id: aid),
          year_over_year: analytics_repo.year_over_year(reports, date_from: date_from, date_to: date_to)
        }
      when "trends"
        dist = analytics_repo.time_distributions(reports, date_from: date_from, date_to: date_to)
        {
          by_dow: dist[:by_dow],
          by_hour: dist[:by_hour],
          monthly_comparison: analytics_repo.monthly_comparison(reports, date_from: date_from, date_to: date_to),
          problem_categories: analytics_repo.problem_categories(reports, date_from: date_from, date_to: date_to),
          top_locations: analytics_repo.top_locations(reports, date_from: date_from, date_to: date_to)
        }
      when "sla"
        {
          sla_by_category: analytics_repo.sla_by_category(reports, date_from: date_from, date_to: date_to),
          sla_by_official: analytics_repo.sla_by_official(alcaldia_id: aid),
          sla_trend: analytics_repo.sla_trend(reports, date_from: date_from, date_to: date_to),
          red_flags: analytics_repo.red_flags(reports, date_from: date_from, date_to: date_to)
        }
      when "satisfaction"
        analytics_repo.satisfaction(reports, date_from: date_from, date_to: date_to)
      when "zonas"
        {
          top_locations: analytics_repo.top_locations(reports, date_from: date_from, date_to: date_to),
          report_by_zone: analytics_repo.report_by_zone(reports, date_from: date_from, date_to: date_to)
        }
      else
        {}
      end

      success(alcaldias: alcaldias, states: states, tab: tab, **tab_data)
    end
  end
end
