import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    console.log('Stimulus CKEditor controller conectado');
    if (!window.ClassicEditor) {
      // Cargar CKEditor desde CDN si no está presente
      const script = document.createElement('script');
      script.src = "https://cdn.ckeditor.com/ckeditor5/classic/39.0.1/ckeditor.js";
      script.onload = () => this.initEditor();
      document.head.appendChild(script);
    } else {
      this.initEditor();
    }
  }

  initEditor() {
    this.textareaTargets.forEach((el) => {
      if (!el.classList.contains('ck-editor-loaded')) {
        window.ClassicEditor.create(el)
          .then(editor => {
            el.classList.add('ck-editor-loaded');
          })
          .catch(error => {
            console.error(error);
          });
      }
    });
  }
}
