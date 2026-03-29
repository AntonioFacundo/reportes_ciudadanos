class Report < ApplicationRecord
  STATUSES = %w[pending read assigned resolved].freeze

  belongs_to :reporter, class_name: "User"
  belongs_to :category
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :resolved_by, class_name: "User", optional: true
  belongs_to :alcaldia

  has_many :resolution_cycles, -> { order(resolved_at: :asc) }, class_name: "ReportResolutionCycle", dependent: :destroy

  has_many_attached :photos
  has_many_attached :resolution_photos

  validates :status, inclusion: { in: STATUSES }
  validates :description, presence: true
  validates :alcaldia_id, presence: true
  validate :location_present

  scope :for_reporter, ->(user) { where(reporter_id: user.id) }

  def pending?
    status == "pending"
  end

  def read?
    status == "read"
  end

  def assigned?
    status == "assigned"
  end

  def resolved?
    status == "resolved"
  end

  def overdue?(category_sla_hours = nil)
    sla = category_sla_hours || category&.sla_hours
    return false unless sla && created_at

    end_time = resolved_at || Time.current
    (end_time - created_at) / 3600.0 > sla
  end

  # Historial ordenado cronológicamente para mostrar en la vista de detalle.
  # Incluye: creación, lectura, ciclos pasados (asignado→resuelto→rechazado) y ciclo actual.
  # Memoizado para evitar recomputar si se accede más de una vez (p. ej. size + each).
  def timeline_items
    @timeline_items ||= build_timeline_items
  end

  def build_timeline_items
    items = []

    items << { type: :created, occurred_at: created_at }
    items << { type: :read, occurred_at: read_at } if read_at.present?

    resolution_cycles.each_with_index do |cycle, idx|
      attempt = idx + 1
      items << { type: :assigned, occurred_at: cycle.assigned_at, cycle: cycle, attempt: attempt } if idx.zero?
      items << { type: :resolved, occurred_at: cycle.resolved_at, cycle: cycle, attempt: attempt }
      items << { type: :rejected, occurred_at: cycle.updated_at, cycle: cycle, attempt: attempt }
    end

    # Asignación actual: solo si no hay ciclos previos (la asignación actual ya está en el último ciclo)
    if assignee.present? && assigned_at.present? && resolution_cycles.empty?
      items << { type: :assigned, occurred_at: assigned_at, current: true }
    end

    if resolved? && resolved_at.present?
      attempt = resolution_cycles.size + 1
      items << { type: :resolved, occurred_at: resolved_at, current: true, attempt: attempt }
      if reporter_accepted_at.present?
        items << { type: :accepted, occurred_at: reporter_accepted_at }
      elsif resolved_at < 72.hours.ago
        items << { type: :auto_closed, occurred_at: resolved_at + 72.hours }
      end
    end

    items.sort_by { |i| i[:occurred_at] || Time.at(0) }
  end

  private

  def location_present
    return if latitude.present? && longitude.present?
    return if location_description.present?
    errors.add(:base, I18n.t("activerecord.errors.models.report.location_required"))
  end
end
