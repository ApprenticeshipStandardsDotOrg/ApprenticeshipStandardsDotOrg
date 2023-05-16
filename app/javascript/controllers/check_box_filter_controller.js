import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "count" ]
  static classes = [ "displayable" ]
  static values = { count: Number }

  connect() {
    this.setCountValue()
  }

  updateCount() {
    const length = this.inputTargets.filter(checkbox => checkbox.checked).length
    this.countValue = length
    this.setCountValue()
  }

  setCountValue() {
    this.countTarget.innerHTML = this.countValue
  }
}
