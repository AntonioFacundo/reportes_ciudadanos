module AdminHelper
  def audit_action_class(action)
    case action.to_s
    when "deactivate_user" then "bg-red-100 text-red-800"
    when "force_state_transition" then "bg-red-100 text-red-800"
    when "destroy_alcaldia" then "bg-red-100 text-red-800"
    when "update_boundary" then "bg-violet-100 text-violet-800"
    when "create_user", "create_alcaldia" then "bg-emerald-100 text-emerald-800"
    else "bg-slate-100 text-slate-700"
    end
  end
end
