# frozen_string_literal: true

module Admin
  class CategoryUpdate < RageArch::UseCase::Base
    use_case_symbol :admin_category_update
    deps :category_repo, :alcaldia_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      category = category_repo.find_scoped(params[:id], user: user)
      return failure(base: I18n.t("errors.not_found")) unless category

      category.alcaldia_id = user.alcaldia_id unless user.system_admin?

      if category_repo.update(category, params[:attrs])
        success(category: category)
      else
        alcaldias = alcaldia_repo.list_available_for_user(user)
        failure(category.errors.to_hash.merge(_record: category, alcaldias: alcaldias))
      end
    end
  end
end
