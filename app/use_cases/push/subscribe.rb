# frozen_string_literal: true

module Push
  class Subscribe < RageArch::UseCase::Base
    use_case_symbol :push_subscribe
    deps :subscription_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      sub = subscription_repo.find_or_build(
        user,
        endpoint: params[:endpoint],
        p256dh: params.dig(:keys, :p256dh),
        auth: params.dig(:keys, :auth)
      )
      return failure(base: I18n.t("errors.invalid")) unless sub

      if subscription_repo.save(sub)
        success(subscription: sub)
      else
        failure(errors: sub.errors.full_messages)
      end
    end
  end
end
