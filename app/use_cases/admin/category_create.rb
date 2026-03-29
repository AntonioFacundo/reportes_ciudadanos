# frozen_string_literal: true

module Admin
  class CategoryCreate < RageArch::UseCase::Base
    use_case_symbol :admin_category_create
    deps :category_repo, :alcaldia_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      category = category_repo.build(params[:attrs])
      category.alcaldia_id = user.alcaldia_id unless user.system_admin?

      if category_repo.save(category)
        success(category: category)
      else
        alcaldias = alcaldia_repo.list_available_for_user(user)
        failure(category.errors.to_hash.merge(_record: category, alcaldias: alcaldias))
      end
    end
  end
end
