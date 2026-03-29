# frozen_string_literal: true

module Reports
  class List < RageArch::UseCase::Base
    use_case_symbol :reports_list
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      base_scope = user.citizen? ? report_repo.for_reporter(user) : Report.none
      filtered = report_repo.apply_filter(base_scope, params[:filter])
      filtered = report_repo.apply_search(
        filtered,
        q: params[:q],
        category_id: params[:category_id],
        status: params[:status],
        date_from: params[:date_from],
        date_to: params[:date_to]
      )
      alcaldia_ids = base_scope.unscope(:order).distinct.pluck(:alcaldia_id)
      categories = report_repo.categories_for_alcaldias(alcaldia_ids)
      success(reports: filtered, categories: categories)
    end
  end
end
