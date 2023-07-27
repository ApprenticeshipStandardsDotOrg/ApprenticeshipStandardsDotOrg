import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pdf-editor"
export default class extends Controller {
  static values = {
    licenseKey: String,
    licenseSerialNumber: String,
  }

  static targets = ["renderTo"]

  connect() {
    new UIExtension.PDFUI({
      viewerOptions: {
        libPath: 'lib',
        jr: {
          licenseKey: this.licenseKeyValue,
          licenseSN: this.licenseSerialNumberValue,
          enginePath: 'jr-engine/gsdk',
          fontPath: 'http://webpdf.foxitsoftware.com/webfonts/'
        }
      },
      renderTo: this.renderToTarget,
      addons: [
        "/lib/uix-addons/file-property",
        "/lib/uix-addons/thumbnail"
      ]
    });
  }
}
