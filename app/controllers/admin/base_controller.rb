# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin_access

    private

    def require_admin_access
      return if Current.user&.system_admin? || Current.user&.mayor?
      redirect_to root_path, alert: I18n.t("errors.unauthorized")
    end

    def require_system_admin
      return if Current.user&.system_admin?
      redirect_to admin_root_path, alert: I18n.t("errors.unauthorized")
    end
  end
end
