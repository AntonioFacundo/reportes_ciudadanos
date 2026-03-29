# frozen_string_literal: true

module Admin
  class CategoryPrepareForm < RageArch::UseCase::Base
    use_case_symbol :admin_category_prepare_form
    deps :category_repo, :alcaldia_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      category = if params[:id].present?
        category_repo.find_scoped(params[:id], user: user)
      else
        category_repo.build
      end

      return failure(base: I18n.t("errors.not_found")) if params[:id].present? && category.nil?

      alcaldias = alcaldia_repo.list_available_for_user(user)
      success(category: category, alcaldias: alcaldias)
    end
  end
end
