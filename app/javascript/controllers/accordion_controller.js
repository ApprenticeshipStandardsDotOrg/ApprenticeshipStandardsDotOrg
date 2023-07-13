import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  changeVisibility(element_id) {
       var panel = document.getElementById(element_id);
       var panelButton = document.getElementById(`${element_id}-button`);
       panel.classList.toggle("hidden")
       panelButton.classList.toggle("hidden")
   }
}
