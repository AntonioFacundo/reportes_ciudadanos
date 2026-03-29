class HomeController < ApplicationController
  def index
    @user = Current.user
    return redirect_to new_session_path unless @user

    if @user.system_admin? || @user.mayor?
      run :home_admin_dashboard, { current_user: @user },
          success: ->(result) {
            @total_reports = result.value[:total_reports]
            @pending_count = result.value[:pending_count]
            @assigned_count = result.value[:assigned_count]
            @resolved_count = result.value[:resolved_count]
            @reopened_count = result.value[:reopened_count]
            @overdue_count = result.value[:overdue_count]
            @leaderboard = result.value[:leaderboard]
            @avg_resolution_by_category = result.value[:avg_resolution_by_category]
            @reports_by_category = result.value[:reports_by_category]
            @recent_reports = result.value[:recent_reports]
            @heatmap_points = result.value[:heatmap_points]
          },
          failure: ->(result) { redirect_to new_session_path, alert: error_messages_from(result) }
    elsif @user.official?
      run :home_official_dashboard, { current_user: @user },
          success: ->(result) {
            @my_assigned_count = result.value[:my_assigned_count]
            @my_resolved_count = result.value[:my_resolved_count]
            @my_pending_count = result.value[:my_pending_count]
            @my_total_count = result.value[:my_total_count]
            @team_workload = result.value[:team_workload]
            @stale_reports = result.value[:stale_reports]
          },
          failure: ->(result) { redirect_to new_session_path, alert: error_messages_from(result) }
    end
  end
end
