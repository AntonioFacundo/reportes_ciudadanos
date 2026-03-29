# frozen_string_literal: true

module Admin
  class SnapshotsIndex < RageArch::UseCase::Base
    use_case_symbol :admin_snapshots_index
    deps :snapshot_repo, :alcaldia_repo, :state_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      base_ids = user.alcaldia_ids_for_admin.presence || Alcaldia.pluck(:id)
      base_ids = Alcaldia.where(id: base_ids).where(state_id: params[:state_id]).pluck(:id) if params[:state_id].present?

      alcaldias = alcaldia_repo.list_by_ids_and_state(base_ids, state_id: params[:state_id])
      states = state_repo.list_ordered

      alcaldia_id = params[:alcaldia_id].presence
      snapshots = snapshot_repo.list_scoped(alcaldia_id: alcaldia_id, base_ids: base_ids)
      chart_data = snapshot_repo.chart_data(alcaldia_id: alcaldia_id, base_ids: base_ids)

      success(alcaldias: alcaldias, states: states, snapshots: snapshots, chart_data: chart_data)
    end
  end
end
