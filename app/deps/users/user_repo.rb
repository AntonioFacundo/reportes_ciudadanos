# frozen_string_literal: true

module Users
  class UserRepo
    def initialize
      @adapter = RageArch::Deps::ActiveRecord.for(User)
    end

    def find(id)
      User.find_by(id: id)
    end

    def find_by_name(name)
      return nil if name.blank?
      User.active.find_by("LOWER(TRIM(name)) = ?", name.to_s.strip.downcase)
    end

    def build(attrs = {})
      @adapter.build(attrs)
    end

    def save(record)
      @adapter.save(record)
    end

    def update(record, attrs)
      @adapter.update(record, attrs)
    end

    def destroy(record)
      @adapter.destroy(record)
    end

    def list(filters: {})
      scope = User.active
      filters.each { |key, value| scope = scope.where(key => value) if value.present? }
      scope.to_a
    end
  end
end
