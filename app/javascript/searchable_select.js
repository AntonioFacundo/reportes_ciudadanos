function initSearchableSelects() {
  document.querySelectorAll("select[data-searchable]").forEach(function(el) {
    if (el.tomselect) return;

    var placeholderText = el.dataset.placeholder || "Escribe para buscar...";
    var blankOption = el.querySelector('option[value=""]');
    if (blankOption) blankOption.textContent = "";

    var hasValue = el.value && el.value !== "";

    var ts = new TomSelect(el, {
      allowEmptyOption: true,
      placeholder: placeholderText,
      render: {
        no_results: function() {
          return '<div class="no-results" style="padding:8px 12px;color:#94a3b8;font-size:0.875rem;">Sin resultados</div>';
        }
      }
    });

    if (!hasValue) {
      ts.clear(true);
    }
  });
}

function destroySearchableSelects() {
  document.querySelectorAll("select[data-searchable]").forEach(function(el) {
    if (el.tomselect) {
      el.tomselect.destroy();
    }
  });
}

document.addEventListener("turbo:before-render", destroySearchableSelects);
document.addEventListener("turbo:load", initSearchableSelects);
document.addEventListener("DOMContentLoaded", initSearchableSelects);
