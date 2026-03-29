# frozen_string_literal: true

module Notifications
  class List < RageArch::UseCase::Base
    use_case_symbol :notifications_list
    deps :notification_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      page = [params[:page].to_i, 1].max
      per_page = 20
      result = notification_repo.list_for_user(user, page: page, per_page: per_page)
      unread_count = notification_repo.unread_count(user)

      success(
        notifications: result[:notifications],
        has_more: result[:has_more],
        page: page,
        unread_count: unread_count
      )
    end
  end
end
