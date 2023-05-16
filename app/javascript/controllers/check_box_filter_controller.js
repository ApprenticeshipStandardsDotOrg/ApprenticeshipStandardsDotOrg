import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "count", "countWrapper" ]
  static classes = [ "displayable" ]
  static values = { count: Number }

  connect() {
    this.updateCount()
  }

  updateCount() {
    const length = this.inputTargets.filter(checkbox => checkbox.checked).length
    this.countValue = length
    this.setCountValue()
  }

  setCountValue() {
    this.countTarget.innerHTML = this.countValue
    if (this.countValue > 0) {
      this.countWrapperTarget.classList.add(this.displayableClass)
    } else {
      this.countWrapperTarget.classList.remove(this.displayableClass)
    }
  }
}
