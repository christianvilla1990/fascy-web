import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subcategoria"]

  connect() {
    // If a category is already selected on load, populate subcategories
    const catId = this.element.value
    if (catId) {
      // call load with a fake event that contains the select as target
      this.load({ target: this.element })
    }
  }

  async load(event) {
    const select = event.target
    const catId = select.value
    const subSelect = this.subcategoriaTarget
    const preselected = subSelect.dataset.selectedValue

    // clear current options
    subSelect.innerHTML = ''
    const blank = document.createElement('option')
    blank.value = ''
    blank.text = ''
    subSelect.appendChild(blank)

    if (!catId) return

    try {
      const resp = await fetch(`/dashboard/categorias/${catId}/subcategorias`, {
        headers: { 'Accept': 'application/json' }
      })
      if (!resp.ok) throw new Error('Network error')
      const subs = await resp.json()
      subs.forEach(s => {
        const opt = document.createElement('option')
        opt.value = s.id
        opt.text = s.nombre
        if (preselected && String(preselected) === String(s.id)) opt.selected = true
        subSelect.appendChild(opt)
      })
    } catch (err) {
      console.error('Failed to load subcategorias', err)
    }
  }
}
