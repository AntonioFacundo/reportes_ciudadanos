# frozen_string_literal: true

module Admin
  class UserUpdate < RageArch::UseCase::Base
    use_case_symbol :admin_user_update
    deps :user_repo, :alcaldia_repo

    def call(params = {})
      current_user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless current_user

      user = User.find_by(id: params[:id])
      return failure(base: I18n.t("errors.not_found")) unless user

      update_params = params[:attrs].except(:password, :password_confirmation)
      update_params[:password] = params[:attrs][:password] if params[:attrs][:password].present?
      update_params[:password_confirmation] = params[:attrs][:password_confirmation] if params[:attrs][:password_confirmation].present?
      update_params[:alcaldia_id] = params[:attrs][:alcaldia_id].presence if user.mayor? && current_user.system_admin?
      if user.official?
        set_official_alcaldia_from_manager(user)
        update_params[:alcaldia_id] = user.alcaldia_id
      end

      if user.update(update_params)
        success(user: user)
      else
        managers = list_managers(current_user, exclude: user.id)
        alcaldias = current_user.system_admin? ? alcaldia_repo.list_ordered : []
        failure(user.errors.to_hash.merge(_record: user, managers: managers, alcaldias: alcaldias))
      end
    end

    private

    def set_official_alcaldia_from_manager(user)
      return unless user.manager_id.present?
      user.alcaldia_id = user.manager&.alcaldia_id if user.manager&.alcaldia_id.present?
    end

    def list_managers(current_user, exclude: nil)
      alcaldia_ids = current_user.alcaldia_ids_for_admin
      scope = User.active.where(role: %w[mayor official]).order(:name)
      scope = scope.where(alcaldia_id: alcaldia_ids) if alcaldia_ids.any?
      scope = scope.where.not(id: exclude) if exclude
      scope
    end
  end
end
