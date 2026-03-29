# frozen_string_literal: true

module Push
  class Unsubscribe < RageArch::UseCase::Base
    use_case_symbol :push_unsubscribe
    deps :subscription_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      subscription = subscription_repo.find_by_endpoint(user, params[:endpoint])
      subscription_repo.destroy(subscription) if subscription
      success(destroyed: true)
    end
  end
end
