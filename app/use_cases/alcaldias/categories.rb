# frozen_string_literal: true

module Alcaldias
  class Categories < RageArch::UseCase::Base
    use_case_symbol :alcaldias_categories

    def call(params = {})
      categories = Category.where(alcaldia_id: params[:id]).order(:name).select(:id, :name)
      success(categories: categories.map { |c| { id: c.id, name: c.name } })
    end
  end
end
