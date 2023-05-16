import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "count", "countWrapper" ]
  static classes = [ "displayable" ]

  connect() {
    this.updateCount()
  }

  updateCount() {
    console.log('in update count')
    const length = this.inputTargets.filter(checkbox => checkbox.checked).length
    this.setCountValue(length)
  }

  setCountValue(length) {
    this.countTarget.innerHTML = length
    if (length > 0) {
      this.countWrapperTarget.classList.add(this.displayableClass)
    } else {
      this.countWrapperTarget.classList.remove(this.displayableClass)
    }
  }
}
