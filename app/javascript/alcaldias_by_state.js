/**
 * Loads alcaldías into the select when a state is chosen.
 * Forms with data-alcaldias-by-state will have their alcaldía dropdown
 * populated only after selecting a state.
 */
function initAlcaldiasByState() {
  document.querySelectorAll("[data-alcaldias-by-state]").forEach((form) => {
    const stateSelect = form.querySelector('select[name="state_id"]')
    const alcaldiaSelect = form.querySelector('select[name="alcaldia_id"]')
    if (!stateSelect || !alcaldiaSelect) return

    const url = form.dataset.alcaldiasByStateUrl || "/admin/alcaldias/by_state"
    const allOptionLabel = form.dataset.alcaldiasByStateAllLabel || "Todas"
    const placeholderLabel = form.dataset.alcaldiasByStatePlaceholder || "Selecciona un estado primero"

    function clearAlcaldias() {
      alcaldiaSelect.innerHTML = ""
      const opt = document.createElement("option")
      opt.value = ""
      opt.textContent = placeholderLabel
      opt.disabled = true
      opt.selected = true
      alcaldiaSelect.appendChild(opt)
      alcaldiaSelect.disabled = true
    }

    function loadAlcaldias(stateId, selectedAlcaldiaId) {
      if (!stateId) {
        clearAlcaldias()
        return
      }

      alcaldiaSelect.disabled = true
      alcaldiaSelect.innerHTML = `<option value="">Cargando...</option>`

      fetch(`${url}?state_id=${encodeURIComponent(stateId)}`, {
        headers: { Accept: "application/json" }
      })
        .then((r) => r.json())
        .then((data) => {
          alcaldiaSelect.innerHTML = ""
          const allOpt = document.createElement("option")
          allOpt.value = ""
          allOpt.textContent = allOptionLabel
          alcaldiaSelect.appendChild(allOpt)
          data.forEach((a) => {
            const opt = document.createElement("option")
            opt.value = a.id
            opt.textContent = a.name
            if (selectedAlcaldiaId && String(a.id) === String(selectedAlcaldiaId)) {
              opt.selected = true
            }
            alcaldiaSelect.appendChild(opt)
          })
          alcaldiaSelect.disabled = false
        })
        .catch(() => {
          alcaldiaSelect.innerHTML = ""
          const errOpt = document.createElement("option")
          errOpt.value = ""
          errOpt.textContent = "Error al cargar"
          alcaldiaSelect.appendChild(errOpt)
          alcaldiaSelect.disabled = false
        })
    }

    function onStateChange() {
      const stateId = stateSelect.value
      const selectedAlcaldiaId = form.dataset.selectedAlcaldiaId || alcaldiaSelect.value
      loadAlcaldias(stateId, selectedAlcaldiaId)
    }

    stateSelect.addEventListener("change", onStateChange)

    const stateId = stateSelect.value
    if (stateId) {
      const selectedId = form.dataset.selectedAlcaldiaId || ""
      loadAlcaldias(stateId, selectedId)
    } else {
      clearAlcaldias()
    }
  })
}

document.addEventListener("turbo:load", initAlcaldiasByState)
