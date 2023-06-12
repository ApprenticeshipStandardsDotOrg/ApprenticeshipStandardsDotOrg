import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="refresh"
//
const REFRESH_PERIOD_IN_MINUTES = 15
const TIMEOUT = 100000

export default class extends Controller {

  static values = {
    src: String
  }

  connect() {
    this.pollFunc(this.updateLink.bind(this), TIMEOUT, REFRESH_PERIOD_IN_MINUTES * 60 * 1000);
  }

  updateLink() {
    this.element.setAttribute('src', this.srcValue)
  }

  pollFunc(fn, timeout, interval) {
    var startTime = (new Date()).getTime();

    (function p() {
      fn();
      if (((new Date).getTime() - startTime ) <= timeout)  {
        setTimeout(p, interval);
      }
    })();
  }
}
