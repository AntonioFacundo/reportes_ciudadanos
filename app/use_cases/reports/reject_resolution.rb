# frozen_string_literal: true

module Reports
  class RejectResolution < RageArch::UseCase::Base
    use_case_symbol :reports_reject_resolution
    deps :report_repo

    REPLICA_DEADLINE_HOURS = 72

    def call(params = {})
      user = params[:current_user]
      report = report_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless report
      return failure(base: I18n.t("errors.unauthorized")) unless user&.id == report.reporter_id
      return failure(base: I18n.t("reports.reject_resolution.not_resolved")) unless report.resolved?
      return failure(base: I18n.t("reports.reject_resolution.deadline_passed")) unless within_replica_deadline?(report)

      justification = params[:reporter_rejection_note].to_s.strip
      return failure(base: I18n.t("reports.reject_resolution.justification_required")) if justification.blank?

      save_resolution_to_history(report, justification)

      attrs = { status: "assigned", reopened: true, reporter_rejection_note: justification, resolution_note: nil, resolved_at: nil, resolved_by_id: nil, reporter_accepted_at: nil }
      if report_repo.update(report, attrs)
        report.resolution_photos.purge
        success(report: report)
      else
        failure(report.errors.to_hash)
      end
    end

    private

    def save_resolution_to_history(report, reporter_rejection_note)
      ReportResolutionCycle.create!(
        report_id: report.id,
        assignee_id: report.assignee_id,
        resolver_id: report.resolved_by_id || report.assignee_id,
        assigned_at: report.assigned_at,
        assignment_note: report.assignment_note,
        resolution_note: report.resolution_note,
        resolved_at: report.resolved_at,
        reporter_rejection_note: reporter_rejection_note
      ).tap do |cycle|
        report.resolution_photos.each { |att| cycle.photos.attach(att.blob) }
      end
    end

    def within_replica_deadline?(report)
      return false unless report.resolved_at
      report.resolved_at >= REPLICA_DEADLINE_HOURS.hours.ago
    end
  end
end
