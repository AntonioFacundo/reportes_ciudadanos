# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      run :admin_users_index, { current_user: Current.user, state_id: params[:state_id], alcaldia_id: params[:alcaldia_id], role: params[:role], q: params[:q] },
          success: ->(result) {
            @pagy, @users = pagy(result.value[:users], items: 25)
            @alcaldias = result.value[:alcaldias]
            @states = result.value[:states]
          },
          failure: ->(result) { redirect_to admin_root_path, alert: error_messages_from(result) }
    end

    def new
      run :admin_user_prepare_form, { current_user: Current.user },
          success: ->(result) {
            @user = result.value[:user]
            @managers = result.value[:managers]
            @alcaldias = result.value[:alcaldias]
          },
          failure: ->(result) { redirect_to admin_users_path, alert: error_messages_from(result) }
    end

    def create
      run :admin_user_create, { current_user: Current.user, attrs: user_params.to_h.symbolize_keys },
          success: ->(result) {
            audit!(:create_user, result.value[:user], role: result.value[:user].role)
            redirect_to admin_users_path, notice: I18n.t("admin.users.created")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @user = errs[:_record] || User.new(user_params)
            @managers = errs[:managers] || []
            @alcaldias = errs[:alcaldias] || []
            flash.now[:alert] = error_messages_from(result)
            render :new, status: :unprocessable_entity
          }
    end

    def edit
      run :admin_user_prepare_form, { current_user: Current.user, id: params[:id] },
          success: ->(result) {
            @user = result.value[:user]
            @managers = result.value[:managers]
            @alcaldias = result.value[:alcaldias]
          },
          failure: ->(result) { redirect_to admin_users_path, alert: error_messages_from(result) }
    end

    def update
      run :admin_user_update, { current_user: Current.user, id: params[:id], attrs: user_params.to_h.symbolize_keys },
          success: ->(result) {
            audit!(:update_user, result.value[:user], role: result.value[:user].role)
            redirect_to admin_users_path, notice: I18n.t("admin.users.updated")
          },
          failure: ->(result) {
            errs = result.errors.is_a?(Hash) ? result.errors : {}
            @user = errs[:_record]
            @managers = errs[:managers] || []
            @alcaldias = errs[:alcaldias] || []
            flash.now[:alert] = error_messages_from(result)
            render :edit, status: :unprocessable_entity
          }
    end

    def deactivate
      run :admin_user_deactivate, { current_user: Current.user, id: params[:id] },
          success: ->(result) {
            user = result.value[:user]
            audit!(:deactivate_user, user, role: user.role, name: user.name)
            redirect_to admin_users_path, notice: I18n.t("admin.users.deactivated")
          },
          failure: ->(result) { redirect_to admin_users_path, alert: error_messages_from(result) }
    end

    def impersonate
      run :admin_user_impersonate, {
            current_user: Current.user,
            target_user_id: params[:id],
            current_session_id: cookies.signed[:session_id],
            user_agent: request.user_agent,
            ip_address: request.remote_ip
          },
          success: ->(result) {
            target_user = result.value[:target_user]
            audit!(:impersonate_user, target_user, target_name: target_user.name, target_role: target_user.role)

            impersonator_session_id = result.value[:impersonator_session_id]
            cookie_opts = { value: impersonator_session_id, httponly: true, same_site: :lax }
            cookie_opts[:secure] = true if request.ssl?
            cookies.signed[:impersonator_session_id] = cookie_opts

            new_session = result.value[:session]
            Current.session = new_session
            cookie_opts = { value: new_session.id, httponly: true, same_site: :lax }
            cookie_opts[:secure] = true if request.ssl?
            cookies.signed.permanent[:session_id] = cookie_opts

            redirect_to root_path, notice: I18n.t("admin.users.impersonate.success", name: target_user.name)
          },
          failure: ->(result) {
            redirect_to admin_users_path, alert: error_messages_from(result)
          }
    end

    def stop_impersonating
      run :admin_user_stop_impersonating, {
            impersonator_session_id: cookies.signed[:impersonator_session_id]
          },
          success: ->(result) {
            impersonator_session = result.value[:session]
            Current.session.destroy
            Current.session = impersonator_session

            cookie_opts = { value: impersonator_session.id, httponly: true, same_site: :lax }
            cookie_opts[:secure] = true if request.ssl?
            cookies.signed.permanent[:session_id] = cookie_opts
            cookies.delete(:impersonator_session_id)

            redirect_to admin_users_path, notice: I18n.t("admin.users.impersonate.stopped")
          },
          failure: ->(result) {
            cookies.delete(:impersonator_session_id) if result.errors[:clear_impersonator_cookie]
            redirect_to root_path, alert: error_messages_from(result)
          }
    end

    private

    def user_params
      params.require(:user).permit(:name, :email_address, :role, :manager_id, :alcaldia_id, :password, :password_confirmation)
    end
  end
end
