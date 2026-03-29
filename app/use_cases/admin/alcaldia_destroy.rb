# frozen_string_literal: true

module Admin
  class AlcaldiaDestroy < RageArch::UseCase::Base
    use_case_symbol :admin_alcaldia_destroy
    deps :alcaldia_repo

    def call(params = {})
      alcaldia = alcaldia_repo.find(params[:id])
      return failure(base: I18n.t("errors.not_found")) unless alcaldia

      if alcaldia_repo.has_dependencies?(alcaldia)
        return failure(base: I18n.t("admin.alcaldias.destroy.has_users_or_reports"))
      end

      if alcaldia_repo.destroy(alcaldia)
        success(alcaldia: alcaldia)
      else
        failure(base: I18n.t("admin.alcaldias.destroy.failed"))
      end
    end
  end
end
