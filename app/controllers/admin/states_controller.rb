# frozen_string_literal: true

module Admin
  class StatesController < BaseController
    before_action :require_system_admin

    def index
      run :admin_states_index, {},
          success: ->(result) {
            @pagy, @states = pagy(result.value[:states], items: 25)
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end

    def new
      run :admin_state_prepare_form, {},
          success: ->(result) { @state = result.value[:state] },
          failure: ->(result) { redirect_to admin_states_path, alert: error_messages_from(result) }
    end

    def create
      run :admin_state_create, { attrs: state_params.to_h },
          success: ->(result) {
            audit!(:create_state, result.value[:state])
            redirect_to admin_states_path, notice: I18n.t("admin.states.created")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @state = errs[:_record] || State.new(state_params)
            flash.now[:alert] = error_messages_from(result)
            render :new, status: :unprocessable_entity
          }
    end

    def edit
      run :admin_state_prepare_form, { id: params[:id] },
          success: ->(result) { @state = result.value[:state] },
          failure: ->(result) { redirect_to admin_states_path, alert: error_messages_from(result) }
    end

    def update
      run :admin_state_update, { id: params[:id], attrs: state_params.to_h },
          success: ->(result) {
            audit!(:update_state, result.value[:state])
            redirect_to admin_states_path, notice: I18n.t("admin.states.updated")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @state = errs[:_record]
            flash.now[:alert] = error_messages_from(result)
            render :edit, status: :unprocessable_entity
          }
    end

    def destroy
      run :admin_state_destroy, { id: params[:id] },
          success: ->(result) {
            audit!(:destroy_state, result.value[:state], name: result.value[:state].name)
            redirect_to admin_states_path, notice: I18n.t("admin.states.destroyed")
          },
          failure: ->(result) { redirect_to admin_states_path, alert: error_messages_from(result) }
    end

    private

    def state_params
      params.require(:state).permit(:name, :code)
    end
  end
end
