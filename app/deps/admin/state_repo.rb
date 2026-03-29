# frozen_string_literal: true

module Admin
  class StateRepo
    def find(id)
      State.find_by(id: id)
    end

    def build(attrs = {})
      State.new(attrs)
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

    def list_ordered
      State.ordered
    end

    def list_with_counts
      State.select(
        "states.*",
        "(SELECT COUNT(*) FROM alcaldias WHERE alcaldias.state_id = states.id) AS alcaldias_count"
      ).order(:name)
    end

    def has_dependencies?(record)
      record.alcaldias.any?
    end
  end
end
