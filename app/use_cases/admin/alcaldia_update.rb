# frozen_string_literal: true

module Admin
  class AlcaldiaUpdate < RageArch::UseCase::Base
    use_case_symbol :admin_alcaldia_update
    deps :alcaldia_repo, :state_repo

    def call(params = {})
      alcaldia = alcaldia_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless alcaldia

      if alcaldia_repo.update(alcaldia, params[:attrs])
        boundary_changed = false
        geojson = params[:boundary_geojson].to_s.strip

        if geojson.present?
          begin
            alcaldia.boundary_from_geojson(geojson)
            boundary_changed = true
          rescue ActiveRecord::StatementInvalid
            states = state_repo.list_ordered
          return failure(base: I18n.t("admin.alcaldias.boundary_invalid"), _record: alcaldia, boundary_geojson: geojson, states: states)
          end
        elsif params[:clear_boundary]
          alcaldia.class.connection.execute(
            ActiveRecord::Base.sanitize_sql_array(["UPDATE alcaldias SET boundary = NULL WHERE id = ?", alcaldia.id])
          )
          alcaldia.reload
          boundary_changed = true
        end

        success(alcaldia: alcaldia, boundary_changed: boundary_changed, geojson_present: geojson.present?)
      else
        states = state_repo.list_ordered
        failure(alcaldia.errors.to_hash.merge(_record: alcaldia, boundary_geojson: params[:boundary_geojson], states: states))
      end
    end
  end
end
