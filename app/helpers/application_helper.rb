module ApplicationHelper
  def role_label(role)
    I18n.t("admin.roles.#{role}", default: role.to_s.humanize)
  end

  def admin_role_options
    roles = []
    roles << ["Alcalde (Presidente Municipal)", "mayor"] if Current.user&.system_admin?
    roles << ["Funcionario", "official"]
    roles
  end

  def report_display_status(report)
    if report.reopened? && report.reporter_rejection_note.present?
      "rejected"
    elsif report.reopened?
      "reopened"
    else
      report.status
    end
  end

  def status_badge_class(status)
    case status.to_s
    when "pending" then "bg-amber-100 text-amber-800"
    when "read" then "bg-blue-100 text-blue-800"
    when "assigned" then "bg-violet-100 text-violet-800"
    when "resolved" then "bg-emerald-100 text-emerald-800"
    when "reopened" then "bg-amber-100 text-amber-800"
    when "rejected" then "bg-red-100 text-red-800"
    else "bg-slate-100 text-slate-700"
    end
  end

  def sla_badge(report)
    return unless report.overdue?
    content_tag(:span, t("status.overdue"), class: "ml-1 px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800")
  end
end
