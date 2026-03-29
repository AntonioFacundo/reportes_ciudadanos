# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      run :admin_dashboard_index, { current_user: Current.user, alcaldia_id: params[:alcaldia_id], state_id: params[:state_id] },
          success: ->(result) {
            @alcaldias = result.value[:alcaldias]
            @states = result.value[:states]
            @alcaldias_count = result.value[:alcaldias_count]
            @states_count = result.value[:states_count]
            @categories_count = result.value[:categories_count]
            @users_count = result.value[:users_count]
            @citizens_count = result.value[:citizens_count]
            @reports_pending = result.value[:reports_pending]
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end
  end
end
