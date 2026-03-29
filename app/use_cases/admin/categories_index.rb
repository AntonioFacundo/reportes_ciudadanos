# frozen_string_literal: true

module Admin
  class CategoriesIndex < RageArch::UseCase::Base
    use_case_symbol :admin_categories_index
    deps :category_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      categories = category_repo.list_scoped(user: user)
      success(categories: categories)
    end
  end
end
