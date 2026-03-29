# frozen_string_literal: true

module Admin
  class CategoryRepo
    def initialize
      @adapter = RageArch::Deps::ActiveRecord.for(Category)
    end

    def find(id)
      Category.find_by(id: id)
    end

    def find_scoped(id, user:)
      scoped_categories(user).find_by(id: id)
    end

    def build(attrs = {})
      Category.new(attrs)
    end

    def save(record)
      record.save
    end

    def update(record, attrs)
      record.assign_attributes(attrs)
      record.save
    end

    def destroy(record)
      record.destroy
    end

    def list_scoped(user:)
      if user.system_admin?
        Category.joins(:alcaldia).includes(:alcaldia).order("alcaldias.name, categories.name")
      else
        Category.where(alcaldia_id: user.alcaldia_id).order(:name)
      end
    end

    def has_reports?(record)
      record.reports.any?
    end

    private

    def scoped_categories(user)
      if user.system_admin?
        Category.all
      else
        Category.where(alcaldia_id: user.alcaldia_id)
      end
    end
  end
end
