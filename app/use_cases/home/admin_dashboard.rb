# frozen_string_literal: true

module Home
  class AdminDashboard < RageArch::UseCase::Base
    use_case_symbol :home_admin_dashboard
    deps :dashboard_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user&.system_admin? || user&.mayor?

      data = dashboard_repo.admin_dashboard(user)
      success(data)
    end
  end
end
