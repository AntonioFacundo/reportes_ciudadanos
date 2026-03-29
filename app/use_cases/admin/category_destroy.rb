# frozen_string_literal: true

module Admin
  class CategoryDestroy < RageArch::UseCase::Base
    use_case_symbol :admin_category_destroy
    deps :category_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      category = category_repo.find_scoped(params[:id], user: user)
      return failure(base: I18n.t("errors.not_found")) unless category

      if category_repo.has_reports?(category)
        return failure(base: I18n.t("admin.categories.destroy.has_reports"))
      end

      if category_repo.destroy(category)
        success(category: category)
      else
        failure(base: I18n.t("admin.categories.destroy.failed"))
      end
    end
  end
end
