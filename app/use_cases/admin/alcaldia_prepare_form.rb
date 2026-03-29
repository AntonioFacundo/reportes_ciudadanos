# frozen_string_literal: true

module Admin
  class AlcaldiaPrepareForm < RageArch::UseCase::Base
    use_case_symbol :admin_alcaldia_prepare_form
    deps :alcaldia_repo, :state_repo

    def call(params = {})
      alcaldia = if params[:id].present?
        alcaldia_repo.find(params[:id])
      else
        alcaldia_repo.build
      end

      return failure(base: I18n.t("errors.not_found")) if params[:id].present? && alcaldia.nil?

      states = state_repo.list_ordered
      boundary_geojson = alcaldia.persisted? ? alcaldia.boundary_as_geojson : nil

      success(alcaldia: alcaldia, states: states, boundary_geojson: boundary_geojson)
    end
  end
end
