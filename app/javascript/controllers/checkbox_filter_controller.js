import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "count", "countWrapper" ]
  static classes = [ "displayable" ]

  connect() {
    this.updateCount()
  }

  updateCount() {
    const length = this.inputTargets.filter(checkbox => checkbox.checked).length
    this.setCountValue(length)
  }

  setCountValue(length) {
    this.countTarget.innerHTML = length
    this.countWrapperTarget.classList.toggle(this.displayableClass, length > 0)
  }
}
