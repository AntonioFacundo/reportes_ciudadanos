class InboxController < ApplicationController
  def index
    run :inbox_list_reports, {
          current_user: Current.user,
          filter: params[:filter],
          q: params[:q],
          category_id: params[:category_id],
          status: params[:status],
          date_from: params[:date_from],
          date_to: params[:date_to]
        },
        success: ->(result) {
          @categories = result.value[:categories]
          @pagy, @reports = pagy(result.value[:reports], items: 15)
        },
        failure: ->(_) { redirect_to root_path, alert: I18n.t("errors.unauthorized") }
  end
end
