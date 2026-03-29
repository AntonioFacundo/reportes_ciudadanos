# frozen_string_literal: true

module Home
  class OfficialDashboard < RageArch::UseCase::Base
    use_case_symbol :home_official_dashboard
    deps :dashboard_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user&.official?

      data = dashboard_repo.official_dashboard(user)
      success(data)
    end
  end
end
