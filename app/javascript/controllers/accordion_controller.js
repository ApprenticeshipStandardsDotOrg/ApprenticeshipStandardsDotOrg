import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "accordion", "expandButton" ]

  changeVisibility() {
       this.accordionTarget.classList.toggle("hidden");
       this.expandButtonTarget.classList.toggle("hidden");
   }
}
