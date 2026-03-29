# frozen_string_literal: true

module Alcaldias
  class Boundary < RageArch::UseCase::Base
    use_case_symbol :alcaldias_boundary
    deps :alcaldia_repo

    def call(params = {})
      alcaldia = alcaldia_repo.find(params[:id])

      if alcaldia&.has_boundary?
        success(boundary: JSON.parse(alcaldia.boundary_as_geojson))
      else
        success(boundary: nil)
      end
    end
  end
end
