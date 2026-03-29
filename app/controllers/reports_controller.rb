class ReportsController < ApplicationController
  def index
    run :reports_list, {
          current_user: Current.user, filter: params[:filter],
          q: params[:q], category_id: params[:category_id], status: params[:status],
          date_from: params[:date_from], date_to: params[:date_to]
        },
        success: ->(result) {
          @categories = result.value[:categories]
          @pagy, @reports = pagy(result.value[:reports], items: 15)
        },
        failure: ->(result) { redirect_to root_path, alert: error_messages_from(result) }
  end

  def new
    run :reports_prepare_new, {},
        success: ->(result) { @categories = result.value[:categories]; @alcaldias = result.value[:alcaldias]; @report = result.value[:report] },
        failure: ->(_) { redirect_to reports_path }
  end

  def create
    run :reports_create, report_params.to_h.symbolize_keys.merge(current_user: Current.user),
        success: ->(result) {
          redirect_to report_path(result.value[:report]), notice: I18n.t("reports.created")
        },
        failure: ->(result) {
          errs = result.errors.is_a?(Hash) ? result.errors : result.errors.to_h
          if errs[:invalid_report]
            @categories = Array(errs[:categories]).compact
            @alcaldias = Array(errs[:alcaldias]).compact
            @report = errs[:invalid_report]
            flash.now[:alert] = error_messages_from(result)
            render :new, status: :unprocessable_entity
          else
            redirect_to reports_path, alert: error_messages_from(result)
          end
        }
  end

  def show
    run :reports_show, { id: params[:id], current_user: Current.user },
        success: ->(result) {
          @report = result.value[:report]
          @assignable = result.value[:assignable] || []
        },
        failure: ->(result) {
          errs = result.errors.respond_to?(:to_h) ? result.errors.to_h : {}
          alert_msg = Array(errs[:base]).first
          redirect_to root_path, alert: alert_msg.presence || error_messages_from(result)
        }
  end

  def mark_read
    run :reports_mark_as_read, { id: params[:id], current_user: Current.user },
        success: ->(result) {
          redirect_to report_path(result.value[:report]), notice: I18n.t("reports.mark_read.success")
        },
        failure: ->(result) { redirect_to report_path(params[:id]), alert: error_messages_from(result) }
  end

  def assign
    run :reports_assign, {
      id: params[:id],
      assignee_id: (params[:assignee_id] || params[:report]&.dig(:assignee_id)),
      assignment_note: (params[:assignment_note] || params[:report]&.dig(:assignment_note)),
      current_user: Current.user
    },
        success: ->(result) {
          redirect_to report_path(result.value[:report]), notice: I18n.t("reports.assign.success")
        },
        failure: ->(result) { redirect_to report_path(params[:id]), alert: error_messages_from(result) }
  end

  def reject_resolution
    run :reports_reject_resolution, { id: params[:id], reporter_rejection_note: (params[:reporter_rejection_note] || params[:report]&.dig(:reporter_rejection_note)), current_user: Current.user },
        success: ->(result) {
          redirect_to report_path(result.value[:report]), notice: I18n.t("reports.reject_resolution.success")
        },
        failure: ->(result) { redirect_to report_path(params[:id]), alert: result.errors[:base]&.first || error_messages_from(result) }
  end

  def accept_resolution
    run :reports_accept_resolution, { id: params[:id], current_user: Current.user },
        success: ->(result) {
          redirect_to report_path(result.value[:report]), notice: I18n.t("reports.accept_resolution.success")
        },
        failure: ->(result) { redirect_to report_path(params[:id]), alert: result.errors[:base]&.first || error_messages_from(result) }
  end

  def resolve
    note = params[:resolution_note].presence || params["resolution_note"].presence
    photos = params[:resolution_photos].presence || params["resolution_photos"].presence
    run :reports_resolve, {
      id: params[:id],
      resolution_note: note,
      photos: photos,
      resolution_photos: photos,
      current_user: Current.user
    },
        success: ->(result) {
          redirect_to report_path(result.value[:report]), notice: I18n.t("reports.resolve.success")
        },
        failure: ->(result) {
          errs = result.errors.is_a?(Hash) ? result.errors : (result.errors.respond_to?(:to_h) ? result.errors.to_h : {})
          if errs[:report].present?
            @report = errs[:report]
            @assignable = Array(errs[:assignable]).presence || []
            flash.now[:alert] = error_messages_from(result)
            render :show, status: :unprocessable_entity
          else
            redirect_to report_path(params[:id]), alert: error_messages_from(result)
          end
        }
  end

  def force_transition
    run :reports_force_transition, { id: params[:id], status: params[:status], current_user: Current.user },
        success: ->(result) {
          report = result.value[:report]
          audit!(:force_state_transition, report, from: result.value[:old_status], to: result.value[:new_status])
          redirect_to report_path(report), notice: I18n.t("admin.reports.force_transition.success", from: result.value[:old_status], to: result.value[:new_status])
        },
        failure: ->(result) {
          redirect_to (params[:id] ? report_path(params[:id]) : root_path), alert: error_messages_from(result)
        }
  end

  private

  def report_params
    (params[:report] || params).permit(:category_id, :alcaldia_id, :description, :latitude, :longitude, :location_description, photos: [])
  end

end
