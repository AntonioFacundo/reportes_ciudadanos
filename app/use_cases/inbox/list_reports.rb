# frozen_string_literal: true

module Inbox
  class ListReports < RageArch::UseCase::Base
    use_case_symbol :inbox_list_reports
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user&.government?

      base = if user.mayor? || user.system_admin?
        report_repo.for_mayor(filter: params[:filter], user: user)
      else
        report_repo.for_official(user, filter: params[:filter])
      end

      reports = report_repo.apply_search(
        base,
        q: params[:q],
        category_id: params[:category_id],
        status: params[:status],
        date_from: params[:date_from],
        date_to: params[:date_to]
      ).includes(:category, :reporter, :assignee, :alcaldia).order(Arel.sql("COALESCE(assigned_at, reports.created_at) DESC"))

      alcaldia_id = user.alcaldia_id || user.manager&.alcaldia_id
      categories = alcaldia_id ? Category.for_alcaldia(alcaldia_id).order(:name) : Category.order(:name)

      success(reports: reports, categories: categories)
    end
  end
end
