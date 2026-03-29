# frozen_string_literal: true

module Admin
  class AuditLogsController < BaseController
    before_action :require_system_admin

    def index
      run :admin_audit_logs_index, {},
          success: ->(result) {
            @pagy, @logs = pagy(result.value[:logs], items: 25)
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end
  end
end
