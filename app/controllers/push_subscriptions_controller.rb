# frozen_string_literal: true

class PushSubscriptionsController < ApplicationController
  def create
    return head :unauthorized unless authenticated?

    run :push_subscribe, { current_user: Current.user, endpoint: params[:endpoint], keys: params[:keys] },
        success: ->(_) { head :created },
        failure: ->(result) {
          errs = result.errors.is_a?(Hash) ? result.errors : {}
          render json: { errors: errs[:errors] || [error_messages_from(result)] }, status: :unprocessable_entity
        }
  end

  def destroy
    return head :unauthorized unless authenticated?

    endpoint = params[:endpoint].presence
    if endpoint.blank? && request.raw_post.present?
      endpoint = ActiveSupport::JSON.decode(request.raw_post).dig("endpoint")
    end

    run :push_unsubscribe, { current_user: Current.user, endpoint: endpoint },
        success: ->(_) { head :no_content },
        failure: ->(_) { head :no_content }
  end

  def vapid_public_key
    return head :unauthorized unless authenticated?

    key = Rails.application.credentials.dig(:vapid, :public_key)
    return head :internal_server_error if key.blank?

    render json: { publicKey: key }
  end
end
