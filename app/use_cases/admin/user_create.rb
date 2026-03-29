# frozen_string_literal: true

module Admin
  class UserCreate < RageArch::UseCase::Base
    use_case_symbol :admin_user_create
    deps :user_repo, :alcaldia_repo

    def call(params = {})
      current_user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless current_user

      user = User.new(params[:attrs])
      user.role = params[:attrs][:role].presence || "official"
      user.alcaldia_id = params[:attrs][:alcaldia_id].presence if user.mayor? && current_user.system_admin?
      set_official_alcaldia_from_manager(user) if user.official?

      if user.save
        success(user: user)
      else
        managers = list_managers(current_user, exclude: nil)
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
