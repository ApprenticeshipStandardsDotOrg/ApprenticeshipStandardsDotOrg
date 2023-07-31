import { Controller } from "@hotwired/stimulus"
import typeahead from 'typeahead-standalone';

export default class extends Controller {
  // Input where the typeahead will be hooked
  static targets = ["input"]
  // Details:
  // src: the data source. Must return an array. URL must include a wildcard, which will be replaced
  // with the value from the input
  // wildcard: the string used as a wildcard
  // identifier: the key from the returned objects used to display as suggestion in the typeahead dropdown
  static values = {
    src: { type: String, default: "/search.json?q=WILDCARD"},
    wildcard: { type: String, default: "WILDCARD" },
    identifier: { type: String, default: "name"},
  }

  connect() {
    this.instance = typeahead({
      input: this.inputTarget,
      source: {
        identifier: this.identifierValue,
        remote: {
          url: this.srcValue,
          wildcard: this.wildcardValue,
        },
      },
      // Override display callback to visit the link when clicking a suggestion instead of
      // autocompleting the input with the suggestion.
      display: (item, event) => {
        if (event) {
          Turbo.visit(`${item.link}?q=${this.inputTarget.value}`)
        }

        return this.inputTarget.value;
      },
      highlight: true
    })
  }

  disconnect() {
    this.instance.destroy();
  }
}
