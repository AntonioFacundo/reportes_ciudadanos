# frozen_string_literal: true

module Admin
  class SnapshotsController < BaseController
    def index
      run :admin_snapshots_index, { current_user: Current.user, state_id: params[:state_id], alcaldia_id: params[:alcaldia_id] },
          success: ->(result) {
            @alcaldias = result.value[:alcaldias]
            @states = result.value[:states]
            @pagy, @snapshots = pagy(result.value[:snapshots], items: 30)
            @chart_data = result.value[:chart_data]
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end

    def capture
      run :admin_snapshot_capture, {},
          success: ->(_) { redirect_to admin_snapshots_path, notice: I18n.t("admin.snapshots.captured") },
          failure: ->(_) { redirect_to admin_snapshots_path, alert: I18n.t("admin.snapshots.capture_failed") }
    end
  end
end
