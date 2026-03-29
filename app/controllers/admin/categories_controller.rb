# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController
    def index
      run :admin_categories_index, { current_user: Current.user },
          success: ->(result) {
            @pagy, @categories = pagy(result.value[:categories], items: 25)
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end

    def new
      run :admin_category_prepare_form, { current_user: Current.user },
          success: ->(result) {
            @category = result.value[:category]
            @alcaldias = result.value[:alcaldias]
          },
          failure: ->(result) { redirect_to admin_categories_path, alert: error_messages_from(result) }
    end

    def create
      run :admin_category_create, { current_user: Current.user, attrs: category_params.to_h },
          success: ->(result) {
            redirect_to admin_categories_path, notice: I18n.t("admin.categories.created")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @category = errs[:_record] || Category.new(category_params)
            @alcaldias = errs[:alcaldias] || []
            flash.now[:alert] = error_messages_from(result)
            render :new, status: :unprocessable_entity
          }
    end

    def edit
      run :admin_category_prepare_form, { current_user: Current.user, id: params[:id] },
          success: ->(result) {
            @category = result.value[:category]
            @alcaldias = result.value[:alcaldias]
          },
          failure: ->(result) { redirect_to admin_categories_path, alert: error_messages_from(result) }
    end

    def update
      run :admin_category_update, { current_user: Current.user, id: params[:id], attrs: category_params.to_h },
          success: ->(result) {
            redirect_to admin_categories_path, notice: I18n.t("admin.categories.updated")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @category = errs[:_record]
            @alcaldias = errs[:alcaldias] || []
            flash.now[:alert] = error_messages_from(result)
            render :edit, status: :unprocessable_entity
          }
    end

    def destroy
      run :admin_category_destroy, { current_user: Current.user, id: params[:id] },
          success: ->(result) {
            redirect_to admin_categories_path, notice: I18n.t("admin.categories.destroyed")
          },
          failure: ->(result) { redirect_to admin_categories_path, alert: error_messages_from(result) }
    end

    private

    def category_params
      permitted = [:name, :sla_hours]
      permitted << :alcaldia_id if Current.user.system_admin?
      params.require(:category).permit(*permitted)
    end
  end
end
