# frozen_string_literal: true

module Reports
  class Create < RageArch::UseCase::Base
    use_case_symbol :reports_create
    deps :report_repo

    def call(params = {})
      user = params[:current_user]
      return failure(base: I18n.t("errors.unauthorized")) unless user

      alcaldia = Alcaldia.find_by(id: params[:alcaldia_id])
      lat = params[:latitude].presence
      lng = params[:longitude].presence

      if lat.present? && lng.present? && alcaldia&.has_boundary? && !alcaldia.contains_point?(lat, lng)
        report = report_repo.build(
          reporter_id: user.id, category_id: params[:category_id], alcaldia_id: params[:alcaldia_id],
          description: params[:description], latitude: lat, longitude: lng,
          location_description: params[:location_description].presence
        )
        return failure(
          { base: I18n.t("reports.create.outside_boundary") }.merge(
            invalid_report: report,
            categories: report_repo.list_categories(alcaldia_id: params[:alcaldia_id]),
            alcaldias: report_repo.list_alcaldias
          )
        )
      end

      report = report_repo.build(
        reporter_id: user.id,
        category_id: params[:category_id],
        alcaldia_id: params[:alcaldia_id],
        description: params[:description],
        latitude: lat,
        longitude: lng,
        location_description: params[:location_description].presence
      )

      report.photos.attach(params[:photos]) if params[:photos].present?

      if report_repo.save(report)
        success(report: report)
      else
        failure(
          report.errors.to_hash.merge(
            invalid_report: report,
            categories: report_repo.list_categories(alcaldia_id: params[:alcaldia_id]),
            alcaldias: report_repo.list_alcaldias
          )
        )
      end
    end
  end
end
