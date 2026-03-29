# frozen_string_literal: true

module Admin
  class AlcaldiasController < BaseController
    before_action :require_system_admin

    def by_state
      run :admin_alcaldias_by_state, { state_id: params[:state_id] },
          success: ->(result) { render json: result.value[:alcaldias] },
          failure: ->(_) { render json: [], status: :unprocessable_entity }
    end

    def index
      run :admin_alcaldias_index, { state_id: params[:state_id] },
          success: ->(result) {
            @states = result.value[:states]
            @pagy, @alcaldias = pagy(result.value[:alcaldias], items: 25)
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end

    def new
      run :admin_alcaldia_prepare_form, {},
          success: ->(result) {
            @alcaldia = result.value[:alcaldia]
            @states = result.value[:states]
          },
          failure: ->(result) { redirect_to admin_alcaldias_path, alert: error_messages_from(result) }
    end

    def create
      run :admin_alcaldia_create, { attrs: alcaldia_params.to_h },
          success: ->(result) {
            audit!(:create_alcaldia, result.value[:alcaldia])
            redirect_to admin_alcaldias_path, notice: I18n.t("admin.alcaldias.created")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @alcaldia = errs[:_record] || Alcaldia.new(alcaldia_params)
            @states = errs[:states].presence || State.ordered
            flash.now[:alert] = error_messages_from(result)
            render :new, status: :unprocessable_entity
          }
    end

    def edit
      run :admin_alcaldia_prepare_form, { id: params[:id] },
          success: ->(result) {
            @alcaldia = result.value[:alcaldia]
            @boundary_geojson = result.value[:boundary_geojson]
            @states = result.value[:states]
          },
          failure: ->(result) { redirect_to admin_alcaldias_path, alert: error_messages_from(result) }
    end

    def update
      run :admin_alcaldia_update, {
            id: params[:id],
            attrs: alcaldia_params.to_h,
            boundary_geojson: params.dig(:alcaldia, :boundary_geojson),
            clear_boundary: params[:alcaldia].key?(:boundary_geojson) && params.dig(:alcaldia, :boundary_geojson).to_s.strip.blank?
          },
          success: ->(result) {
            alcaldia = result.value[:alcaldia]
            audit!(:update_boundary, alcaldia, boundary_set: result.value[:geojson_present]) if result.value[:boundary_changed]
            audit!(:update_alcaldia, alcaldia)
            redirect_to admin_alcaldias_path, notice: I18n.t("admin.alcaldias.updated")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @alcaldia = errs[:_record]
            @states = errs[:states].presence || State.ordered
            @boundary_geojson = errs[:boundary_geojson] || params.dig(:alcaldia, :boundary_geojson)
            flash.now[:alert] = error_messages_from(result)
            render :edit, status: :unprocessable_entity
          }
    end

    def destroy
      run :admin_alcaldia_destroy, { id: params[:id] },
          success: ->(result) {
            alcaldia = result.value[:alcaldia]
            audit!(:destroy_alcaldia, alcaldia, name: alcaldia.name)
            redirect_to admin_alcaldias_path, notice: I18n.t("admin.alcaldias.destroyed")
          },
          failure: ->(result) { redirect_to admin_alcaldias_path, alert: error_messages_from(result) }
    end

    private

    def alcaldia_params
      params.require(:alcaldia).permit(:name, :state_id, :boundary_geojson)
    end
  end
end
