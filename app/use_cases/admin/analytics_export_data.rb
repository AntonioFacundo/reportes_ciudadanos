# frozen_string_literal: true

module Admin
  class AnalyticsExportData < RageArch::UseCase::Base
    use_case_symbol :admin_analytics_export_data
    deps :analytics_repo, :alcaldia_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      base_ids = user.alcaldia_ids_for_admin || []
      all_ids = base_ids.presence || alcaldia_repo.pluck_ids
      all_ids = alcaldia_repo.filter_ids_by_state(all_ids, params[:state_id])

      reports = analytics_repo.scoped_reports(
        alcaldia_id: params[:alcaldia_id].presence,
        base_ids: all_ids,
        date_from: params[:date_from].presence,
        date_to: params[:date_to].presence
      )

      date_from = params[:date_from].presence
      date_to = params[:date_to].presence
      sat = analytics_repo.satisfaction(reports, date_from: date_from, date_to: date_to)

      alcaldia_name = params[:alcaldia_id].present? ? alcaldia_repo.find(params[:alcaldia_id])&.name : nil
      alcaldia_name ||= user.alcaldia&.name if user.mayor?

      data = {
        resolution_rate: analytics_repo.resolution_rate(reports, date_from: date_from, date_to: date_to),
        stage_times: analytics_repo.stage_times(reports, date_from: date_from, date_to: date_to),
        sla_by_category: analytics_repo.sla_by_category(reports, date_from: date_from, date_to: date_to),
        top_locations: analytics_repo.top_locations(reports, date_from: date_from, date_to: date_to),
        total_resolved: sat[:total_resolved],
        accepted_count: sat[:accepted_count],
        rejected_count: sat[:rejected_count],
        no_response_count: sat[:no_response_count]
      }

      success(
        data: data,
        alcaldia_name: alcaldia_name,
        date_from: date_from,
        date_to: date_to
      )
    end
  end
end
