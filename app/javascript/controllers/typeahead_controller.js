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
      display: (item, event) => {
        return item.display;
      },
      templates: {
        suggestion: (item, resultSet) => {
          return `
          <div
            data-action="click->typeahead#navigateTo"
            data-typeahead-display-param="${item.display}"
            data-typeahead-link-param="${item.link}"
            data-typeahead-onet-code-param="${item.onet_code}"
            >
            ${item.display}
          </div>`;
        }
      },
      highlight: true
    })
  }

  navigateTo(event) {
    const {params: item} = event
    event.preventDefault

    Turbo.visit(`${item.link}?q=${item.display}&onet_prefix=${item.onetCode}`)
  }

  disconnect() {
    this.instance.destroy();
  }
}
