# frozen_string_literal: true

module Reports
  class Resolve < RageArch::UseCase::Base
    use_case_symbol :reports_resolve
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      report = report_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless report
      return failure(base: I18n.t("errors.unauthorized")) unless can_resolve?(user, report)
      return failure(base: I18n.t("reports.resolve.invalid_state")) unless report.assigned?

      photo_files = params[:photos].presence || params[:resolution_photos].presence
      has_photos = photo_files.present? && photo_files.respond_to?(:any?) && photo_files.any?
      note = (params[:resolution_note].presence || "").to_s.strip
      has_note = note.present?

      unless has_photos || has_note
        return failure(base: I18n.t("reports.resolve.photo_or_note_required"), report: report, assignable: assignable_list(user))
      end

      report.resolution_note = note.present? ? note : nil
      report.resolution_photos.attach(photo_files) if has_photos
      report.status = "resolved"
      report.resolved_at = Time.current
      report.resolved_by_id = user.id

      update_attrs = { status: "resolved", resolved_at: report.resolved_at, reopened: false, resolved_by_id: user.id }
      update_attrs[:resolution_note] = report.resolution_note
      if report_repo.update(report, update_attrs)
        success(report: report)
      else
        failure(report.errors.to_hash.merge(report: report, assignable: assignable_list(user)))
      end
    end

    private

    def assignable_list(user)
      report_repo.list_assignable_officials(user) if user&.government?
    end

    def can_resolve?(user, report)
      return false unless user&.government?
      return true if user.system_admin?
      user_alcaldia = user.alcaldia_id || user.manager&.alcaldia_id
      return false unless report.alcaldia_id == user_alcaldia
      return true if user.mayor?
      user.official? && report.assignee_id == user.id
    end
  end
end
