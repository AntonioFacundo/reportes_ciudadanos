# frozen_string_literal: true

module Admin
  class UserDeactivate < RageArch::UseCase::Base
    use_case_symbol :admin_user_deactivate

    def call(params = {})
      current_user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless current_user

      user = User.find_by(id: params[:id])
      return failure(base: I18n.t("errors.not_found")) unless user
      return failure(base: I18n.t("admin.users.deactivate.cannot_self")) if user.id == current_user.id

      if user.subordinates.active.any?
        return failure(base: I18n.t("admin.users.deactivate.has_subordinates"))
      end

      if user.reports_as_assignee.where(status: "assigned").any?
        return failure(base: I18n.t("admin.users.deactivate.has_assigned_reports"))
      end

      if user.update(active: false)
        success(user: user)
      else
        failure(base: I18n.t("admin.users.deactivate.failed"))
      end
    end
  end
end
