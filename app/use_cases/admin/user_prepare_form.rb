# frozen_string_literal: true

module Admin
  class UserPrepareForm < RageArch::UseCase::Base
    use_case_symbol :admin_user_prepare_form
    deps :user_repo, :alcaldia_repo

    def call(params = {})
      current_user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless current_user

      user = if params[:id].present?
        user_repo.find(params[:id])
      else
        User.new(role: "official")
      end

      return failure(base: I18n.t("errors.not_found")) if params[:id].present? && user.nil?

      managers = list_managers(current_user, exclude: user&.id)
      alcaldias = current_user.system_admin? ? alcaldia_repo.list_ordered : []

      success(user: user, managers: managers, alcaldias: alcaldias)
    end

    private

    def list_managers(current_user, exclude: nil)
      alcaldia_ids = current_user.alcaldia_ids_for_admin
      scope = User.active.where(role: %w[mayor official]).order(:name)
      scope = scope.where(alcaldia_id: alcaldia_ids) if alcaldia_ids.any?
      scope = scope.where.not(id: exclude) if exclude
      scope
    end
  end
end
