# frozen_string_literal: true

class AlcaldiasController < ApplicationController
  def boundary
    run :alcaldias_boundary, { id: params[:id] },
        success: ->(result) { render json: { boundary: result.value[:boundary] } },
        failure: ->(_) { render json: { boundary: nil } }
  end

  def categories
    run :alcaldias_categories, { id: params[:id] },
        success: ->(result) {
          expires_in 5.minutes, public: true
          render json: result.value[:categories]
        },
        failure: ->(_) { render json: [] }
  end
end
