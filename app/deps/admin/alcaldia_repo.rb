# frozen_string_literal: true

module Admin
  class AlcaldiaRepo
    def initialize
      @adapter = RageArch::Deps::ActiveRecord.for(Alcaldia)
    end

    def find(id)
      Alcaldia.find_by(id: id)
    end

    def build(attrs = {})
      Alcaldia.new(attrs)
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

    def list_with_counts(state_id: nil)
      scope = Alcaldia
        .includes(:state)
        .select("alcaldias.*, (SELECT COUNT(*) FROM users WHERE users.alcaldia_id = alcaldias.id) AS users_count_cache, (SELECT COUNT(*) FROM reports WHERE reports.alcaldia_id = alcaldias.id) AS reports_count_cache")
        .order(:name)
      scope = scope.where(state_id: state_id) if state_id.present?
      scope
    end

    def list_ordered
      Alcaldia.order(:name)
    end

    def list_by_state(state_id)
      scope = Alcaldia.order(:name)
      scope = scope.where(state_id: state_id) if state_id.present?
      scope
    end

    def list_available_for_user(user)
      if user.system_admin?
        Alcaldia.order(:name)
      else
        Alcaldia.where(id: user.alcaldia_id)
      end
    end

    def pluck_ids(state_id: nil)
      scope = Alcaldia
      scope = scope.where(state_id: state_id) if state_id.present?
      scope.pluck(:id)
    end

    def filter_ids_by_state(ids, state_id)
      return ids unless state_id.present? && ids.any?
      Alcaldia.where(id: ids).where(state_id: state_id).pluck(:id)
    end

    def list_by_ids(ids)
      Alcaldia.where(id: ids).order(:name)
    end

    def list_by_ids_and_state(ids, state_id: nil)
      scope = Alcaldia.where(id: ids).order(:name)
      scope = scope.where(state_id: state_id) if state_id.present?
      scope
    end

    def has_dependencies?(record)
      record.users.any? || record.reports.any?
    end
  end
end
