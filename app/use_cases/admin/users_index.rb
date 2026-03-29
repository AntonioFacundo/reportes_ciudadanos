# frozen_string_literal: true

module Admin
  class UsersIndex < RageArch::UseCase::Base
    use_case_symbol :admin_users_index
    deps :user_repo, :alcaldia_repo, :state_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      base_ids = user.alcaldia_ids_for_admin.presence || Alcaldia.pluck(:id)
      base_ids = Alcaldia.where(id: base_ids).where(state_id: params[:state_id]).pluck(:id) if params[:state_id].present?

      scope = User.where(role: %w[mayor official])
      scope = scope.where(alcaldia_id: base_ids)
      scope = scope.where(alcaldia_id: params[:alcaldia_id]) if params[:alcaldia_id].present?
      scope = scope.where(role: params[:role]) if params[:role].present? && %w[mayor official].include?(params[:role])
      scope = scope.where("users.name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      scope = scope.order(:role, :name).includes(:manager, :alcaldia)

      alcaldias = alcaldia_repo.list_by_ids_and_state(base_ids, state_id: params[:state_id])
      states = state_repo.list_ordered
      success(users: scope, alcaldias: alcaldias, states: states)
    end
  end
end
