import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "textField", "checkbox" ]

  clearForm() {
    this.textFieldTargets.forEach(input => input.value = "")
    this.checkboxTargets.forEach(input => input.checked = false)

    const event = new CustomEvent("clearForm");
    window.dispatchEvent(event);
  }
}
