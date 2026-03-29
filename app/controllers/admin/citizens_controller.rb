# frozen_string_literal: true

module Admin
  class CitizensController < BaseController
    before_action :require_system_admin, only: %i[edit update deactivate reactivate]

    def index
      run :admin_citizens_index, { q: params[:q], status: params[:status] },
          success: ->(result) {
            @total = result.value[:total]
            @pagy, @citizens = pagy(result.value[:citizens], items: 30)
            @report_counts = Report.where(reporter_id: @citizens.map(&:id)).group(:reporter_id).count
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end

    def show
      run :admin_citizen_show, { id: params[:id] },
          success: ->(result) {
            @citizen = result.value[:citizen]
            @pagy_reports, @reports = pagy(result.value[:reports], items: 20, page_param: :page)
            @report_counts = result.value[:report_counts]
          },
          failure: ->(result) { redirect_to admin_citizens_path, alert: error_messages_from(result) }
    end

    def edit
      run :admin_citizen_prepare_form, { id: params[:id] },
          success: ->(result) { @citizen = result.value[:citizen] },
          failure: ->(result) { redirect_to admin_citizens_path, alert: error_messages_from(result) }
    end

    def update
      run :admin_citizen_update, { id: params[:id], attrs: citizen_params.to_h },
          success: ->(result) {
            @citizen = result.value[:citizen]
            audit!(:update_citizen, @citizen, name: @citizen.name)
            redirect_to admin_citizen_path(@citizen), notice: I18n.t("admin.citizens.updated")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @citizen = errs[:_record]
            flash.now[:alert] = error_messages_from(result)
            render :edit, status: :unprocessable_entity
          }
    end

    def deactivate
      run :admin_citizen_deactivate, { id: params[:id] },
          success: ->(result) {
            @citizen = result.value[:citizen]
            audit!(:deactivate_citizen, @citizen, name: @citizen.name)
            redirect_to admin_citizens_path, notice: I18n.t("admin.citizens.deactivated", name: @citizen.name)
          },
          failure: ->(result) { redirect_to admin_citizens_path, alert: error_messages_from(result) }
    end

    def reactivate
      run :admin_citizen_reactivate, { id: params[:id] },
          success: ->(result) {
            @citizen = result.value[:citizen]
            audit!(:reactivate_citizen, @citizen, name: @citizen.name)
            redirect_to admin_citizens_path, notice: I18n.t("admin.citizens.reactivated", name: @citizen.name)
          },
          failure: ->(result) { redirect_to admin_citizens_path, alert: error_messages_from(result) }
    end

    private

    def citizen_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
  end
end
