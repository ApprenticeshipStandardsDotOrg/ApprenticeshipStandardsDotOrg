import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "textField", "checkBox" ]

  clearForm() {
    this.textFieldTargets.forEach(input => input.value = "")
    this.checkBoxTargets.forEach(input => input.checked = false)
  }
}
