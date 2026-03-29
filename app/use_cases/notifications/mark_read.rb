# frozen_string_literal: true

module Notifications
  class MarkRead < RageArch::UseCase::Base
    use_case_symbol :notifications_mark_read
    deps :notification_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      notification = notification_repo.find_for_user(user, params[:id])
      return failure(base: I18n.t("errors.not_found")) unless notification

      notification_repo.mark_read!(notification)
      success(notification: notification)
    end
  end
end
