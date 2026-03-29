# frozen_string_literal: true

module Home
  class ShowDashboard < RageArch::UseCase::Base
    use_case_symbol :home_show_dashboard

    def call(params = {})
      user = params[:current_user]
      success(user: user)
    end
  end
end
