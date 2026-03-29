# frozen_string_literal: true

module Admin
  class ExportReportes < RageArch::UseCase::Base
    use_case_symbol :admin_export_reportes
    deps :report_repo, :alcaldia_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user&.government?

      base = user.mayor? || user.system_admin? ? report_repo.for_mayor(filter: nil, user: user) : report_repo.for_official(user, filter: nil)
      base = base.where(alcaldia_id: params[:alcaldia_id]) if params[:alcaldia_id].present? && user.system_admin?
      scope = report_repo.apply_search(
        base,
        q: params[:q],
        category_id: params[:category_id],
        status: params[:status],
        date_from: params[:date_from],
        date_to: params[:date_to]
      ).includes(:category, :alcaldia).order(created_at: :desc)

      alcaldia_name = alcaldia_repo.find(params[:alcaldia_id])&.name if params[:alcaldia_id].present?
      alcaldia_name ||= user.alcaldia&.name if user.mayor?

      success(
        reports: scope,
        alcaldia_name: alcaldia_name,
        date_from: params[:date_from],
        date_to: params[:date_to]
      )
    end
  end
end
