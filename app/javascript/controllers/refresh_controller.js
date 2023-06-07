import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="refresh"
export default class extends Controller {
  static values = {
    src: String
  }

  connect() {
    this.timeout = setTimeout(() => {
      this.element.setAttribute('src', this.srcValue)
    }, 5000);
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
