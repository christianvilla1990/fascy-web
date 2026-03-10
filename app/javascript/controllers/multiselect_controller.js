import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { placeholder: String }

  connect() {
    if (this.initialized) return
    if (!window.TomSelect) {
      const link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = 'https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.css'
      document.head.appendChild(link)

      const script = document.createElement('script')
      script.src = 'https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js'
      script.onload = () => this.init()
      document.head.appendChild(script)
    } else {
      this.init()
    }
  }

  init() {
    try {
      // eslint-disable-next-line no-undef
      new TomSelect(this.element, {
        plugins: ['remove_button'],
        persist: false,
        create: false,
        placeholder: this.placeholderValue || 'Buscar...',
        maxItems: null,
        allowEmptyOption: true
      })
      this.initialized = true
    } catch (e) {
      console.error('TomSelect init error', e)
    }
  }
}
