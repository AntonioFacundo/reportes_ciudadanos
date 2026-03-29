# frozen_string_literal: true

module Admin
  class DashboardIndex < RageArch::UseCase::Base
    use_case_symbol :admin_dashboard_index
    deps :dashboard_repo, :alcaldia_repo, :state_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      base_alcaldia_ids = user.alcaldia_ids_for_admin || []
      all_ids = base_alcaldia_ids.presence || Alcaldia.pluck(:id)

      if params[:state_id].present?
        all_ids = Alcaldia.where(id: all_ids).where(state_id: params[:state_id]).pluck(:id)
      end

      alcaldias = alcaldia_repo.list_by_ids_and_state(all_ids, state_id: params[:state_id])
      states = state_repo.list_ordered

      alcaldia_ids = if params[:alcaldia_id].present?
        [params[:alcaldia_id].to_i] & all_ids
      else
        base_alcaldia_ids.any? ? (all_ids & base_alcaldia_ids) : all_ids
      end

      counts = dashboard_repo.counts(alcaldia_ids: alcaldia_ids)

      success(
        alcaldias: alcaldias,
        states: states,
        alcaldias_count: user.system_admin? ? alcaldia_ids.size : nil,
        **counts
      )
    end
  end
end
