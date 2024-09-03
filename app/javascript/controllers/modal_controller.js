import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal"]

  connect() {
    console.log("Modal....")
    this.modal = new Modal(this.modalTarget, {backdrop: "static"});
    this.modal.show()
  }

  hide() {
    console.log("Hide...")
    this.modal.hide()
  }
}
