# frozen_string_literal: true

module PagyHelper
  def pagy_nav(pagy, path_method: nil, label: nil)
    return "" if pagy.nil? || pagy.pages <= 1

    count_label = label || "registros"

    content_tag(:nav, class: "flex items-center justify-center gap-2 mt-6") do
      prev_link = if pagy.previous
        link_to("← Anterior", pagy_url(pagy.previous, path_method), class: "px-3 py-2 rounded-lg bg-slate-200 text-slate-700 hover:bg-slate-300 text-sm font-medium")
      else
        content_tag(:span, "← Anterior", class: "px-3 py-2 rounded-lg bg-slate-100 text-slate-400 text-sm cursor-not-allowed")
      end

      next_link = if pagy.next
        link_to("Siguiente →", pagy_url(pagy.next, path_method), class: "px-3 py-2 rounded-lg bg-slate-200 text-slate-700 hover:bg-slate-300 text-sm font-medium")
      else
        content_tag(:span, "Siguiente →", class: "px-3 py-2 rounded-lg bg-slate-100 text-slate-400 text-sm cursor-not-allowed")
      end

      concat(prev_link)
      concat content_tag(:span, "Página #{pagy.page} de #{pagy.pages} (#{pagy.count} #{count_label})", class: "px-3 py-2 text-slate-600 text-sm")
      concat(next_link)
    end
  end

  private

  def pagy_url(page, path_method)
    preserved = request.query_parameters.except("page").symbolize_keys.merge(page: page)
    path_method ? send(path_method, preserved) : url_for(preserved)
  end
end
