# frozen_string_literal: true

module Reports
  class ReportRepo
    def initialize
      @adapter = RageArch::Deps::ActiveRecord.for(Report)
    end

    # Eager load todas las asociaciones necesarias para la vista show (incl. historial/timeline).
    # Evita N+1 al acceder a resolution_cycles, assignees, fotos del reporte y de cada ciclo.
    def find(id)
      Report.includes(
        :category, :reporter, :assignee, :resolved_by,
        resolution_cycles: [:assignee, :resolver, { photos_attachments: :blob }],
        photos_attachments: :blob, resolution_photos_attachments: :blob
      ).find_by(id: id)
    end

    def build(attrs = {})
      Report.new(attrs)
    end

    def save(record)
      record.save
    end

    def update(record, attrs)
      record.assign_attributes(attrs)
      record.save
    end

    def for_reporter(user, filter: nil)
      scope = Report.includes(:category).for_reporter(user).order(created_at: :desc)
      apply_reporter_filter(scope, filter)
    end

    def apply_reporter_filter(scope, filter)
      case filter.to_s
      when "pending" then scope.where(status: "pending")
      when "read" then scope.where(status: "read")
      when "assigned" then scope.where(status: "assigned")
      when "resolved" then scope.where(status: "resolved")
      when "rejected" then scope.where(reopened: true).where.not(reporter_rejection_note: [nil, ""])
      when "reopened" then scope.where(reopened: true)
      else scope
      end
    end

    def for_mayor(filter: nil, user: nil)
      scope = Report.includes(:category, :reporter, :assignee, :alcaldia)
                    .order(Arel.sql("COALESCE(assigned_at, created_at) DESC"))
      scope = scope.where(alcaldia_id: user.alcaldia_id) if user&.mayor? && user.alcaldia_id.present?
      apply_mayor_filter(scope, filter)
    end

    def for_official(user, filter: nil)
      ids = user_and_subordinate_ids(user)
      alcaldia_id = user.alcaldia_id || user.manager&.alcaldia_id
      scope = Report.includes(:category, :reporter, :assignee, :alcaldia)
                    .where(assignee_id: ids)
                    .order(assigned_at: :desc)
      scope = scope.where(alcaldia_id: alcaldia_id) if alcaldia_id.present?
      apply_official_filter(scope, user, filter)
    end

    def apply_filter(scope, filter)
      case filter.to_s
      when "pending" then scope.where(status: "pending")
      when "read" then scope.where(status: "read")
      when "assigned" then scope.where(status: "assigned")
      when "resolved" then scope.where(status: "resolved")
      when "rejected" then scope.where(reopened: true).where.not(reporter_rejection_note: [nil, ""])
      when "reopened" then scope.where(reopened: true)
      else scope
      end
    end

    def apply_search(scope, q: nil, category_id: nil, status: nil, date_from: nil, date_to: nil)
      scope = scope.where("description ILIKE ? OR location_description ILIKE ?", "%#{q}%", "%#{q}%") if q.present?
      scope = scope.where(category_id: category_id) if category_id.present?
      scope = apply_status_search(scope, status) if status.present?
      scope = scope.where("reports.created_at >= ?", Date.parse(date_from).beginning_of_day) if date_from.present?
      scope = scope.where("reports.created_at <= ?", Date.parse(date_to).end_of_day) if date_to.present?
      scope
    rescue Date::Error
      scope
    end

    def categories_for_alcaldias(alcaldia_ids)
      Category.where(alcaldia_id: alcaldia_ids).order(:name)
    end

    def list_categories(alcaldia_id: nil)
      scope = Category.order(:name)
      scope = scope.for_alcaldia(alcaldia_id) if alcaldia_id.present?
      scope
    end

    def list_alcaldias
      Alcaldia.order(:name)
    end

    def list_assignable_officials(current_user)
      return User.none unless current_user&.mayor? || current_user&.official?
      alcaldia_id = current_user.alcaldia_id || current_user.manager&.alcaldia_id
      if current_user.mayor?
        scope = User.active.where(role: "official").or(User.active.where(role: "mayor")).where.not(id: current_user.id)
        scope = scope.where(alcaldia_id: alcaldia_id) if alcaldia_id.present?
        scope.order(:name)
      else
        User.active.where(manager_id: current_user.id).or(User.active.where(id: current_user.id)).order(:name)
      end
    end

    private

    def apply_status_search(scope, status)
      case status.to_s
      when "reopened" then scope.where(reopened: true)
      when "rejected" then scope.where(reopened: true).where.not(reporter_rejection_note: [nil, ""])
      else
        Report::STATUSES.include?(status) ? scope.where(status: status) : scope
      end
    end

    def apply_mayor_filter(scope, filter)
      case filter.to_s
      when "por_asignar" then scope.where(status: %w[pending read])
      when "asignados" then scope.where(status: "assigned")
      when "rechazados" then scope.where(reopened: true).where.not(reporter_rejection_note: [nil, ""])
      when "resueltos" then scope.where(status: "resolved")
      else scope
      end
    end

    def apply_official_filter(scope, user, filter)
      case filter.to_s
      when "a_mi" then scope.where(assignee_id: user.id)
      when "a_mi_equipo" then scope.where(assignee_id: user.subordinates.select(:id))
      when "rechazados" then scope.where(reopened: true).where.not(reporter_rejection_note: [nil, ""])
      else scope
      end
    end

    def user_and_subordinate_ids(user)
      ids = User.connection.select_values(
        ActiveRecord::Base.sanitize_sql_array([
          "WITH RECURSIVE tree AS (
            SELECT id FROM users WHERE manager_id = ? AND active = true
            UNION ALL
            SELECT u.id FROM users u INNER JOIN tree t ON u.manager_id = t.id AND u.active = true
          ) SELECT id FROM tree UNION SELECT ?",
          user.id, user.id
        ])
      )
      ids.presence || [user.id]
    end
  end
end
