# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    run :notifications_list, { current_user: Current.user, page: params[:page] },
        success: ->(result) {
          @notifications = result.value[:notifications]
          @has_more = result.value[:has_more]
          @page = result.value[:page]
          @unread_count = result.value[:unread_count]

          if turbo_frame_request?
            render partial: "notifications/page", layout: false
          else
            render :index
          end
        },
        failure: ->(result) { redirect_to root_path, alert: error_messages_from(result) }
  end

  def mark_read
    run :notifications_mark_read, { current_user: Current.user, id: params[:id] },
        success: ->(result) {
          redirect_to result.value[:notification].path.presence || notifications_path, notice: nil
        },
        failure: ->(result) { redirect_to notifications_path, alert: error_messages_from(result) }
  end
end
