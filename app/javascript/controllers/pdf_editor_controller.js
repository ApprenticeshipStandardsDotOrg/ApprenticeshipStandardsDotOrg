import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pdf-editor"
export default class extends Controller {
  static values = {
    licenseKey: String,
    licenseSerialNumber: String,
    fileUrl: String,
    fileName: String,
    saveFileUrl: String,
    goBackUrl: String,
    fileSize: Number,
  }

  static targets = ["renderTo", "form"]

  connect() {
    this.pdfui = new UIExtension.PDFUI({
      viewerOptions: {
        libPath: 'lib',
        jr: {
          licenseKey: this.licenseKeyValue,
          licenseSN: this.licenseSerialNumberValue,
          enginePath: 'jr-engine/gsdk',
          fontPath: 'http://webpdf.foxitsoftware.com/webfonts/'
        },
      },
      appearance: UIExtension.appearances.RibbonAppearance.extend({
        getDefaultFragments: function() {
          return [
            {
              target: 'home-tab-group-hand::childAt(2)',
              action: UIExtension.UIConsts.FRAGMENT_ACTION.AFTER,
              template: `
              <xbutton
              class="fv__ui-toolbar-show-text-button"
              icon-class="fv__icon-float-bar-previous-page"
              data-action="click->pdf-editor#goBack"
              name="select-pdf-file-button"
              >Go back
              </xbutton>
                `
              },
            {
              target: 'home-tab-group-hand::childAt(2)',
              action: UIExtension.UIConsts.FRAGMENT_ACTION.AFTER,
              template: `
                <xbutton
                  class="fv__ui-toolbar-show-text-button"
                  icon-class="fv__icon-search-save"
                  data-action="click->pdf-editor#saveDocument"
                  >Save Document
                </xbutton>
              `
            },
          ];
        }
      }),
      renderTo: this.renderToTarget,
      addons: UIXAddons
    });

    if (this.fileUrlValue && this.fileNameValue) {
      this.pdfui.openPDFByHttpRangeRequest(
        {
          range: {
            url: this.fileUrlValue,
            size: this.fileSizeValue
          },
        },
        { fileName: this.fileNameValue }
      ).then(() => {
        this.pdfui.getPDFViewer().then(viewer => viewer.zoomTo(1))
      });

    }
  }

  goBack(e) {
    e.preventDefault()
    Turbo.visit(this.goBackUrlValue)
  }

  async saveDocument(e) {
    e.preventDefault()
    this.pdfui.getPDFViewer()
      .then(pdfViewer => {
        const buffers = [];
        return pdfViewer.currentPDFDoc
          .getStream(({ arrayBuffer }) => {
            buffers.push(arrayBuffer);
          })
          .then(_ => {
            return [buffers, pdfViewer.currentPDFDoc.getFileName()];
          });
      })
      .then(([buffers, fileName]) => {
        if (!fileName || fileName.length === 0) {
          fileName = "redacted.pdf";
        }
        const blob = new Blob(buffers, {type: 'application/pdf'})
        return [blob, fileName];
      })
      .then(([redactedPdf, fileName]) => {
        const formData = new FormData(this.formTarget);
        formData.append("redacted_file", redactedPdf, fileName)

        fetch(this.saveFileUrlValue, {
          method: "POST",
          body: formData,
        }).then((response) => {
          if (response.status == 200) {
            alert("Redacted document saved for all occupation standards associated to this source file")
            Turbo.visit(this.goBackUrlValue)
          } else {
            alert("Oh no, something went wrong!");
          }
        }).catch((err) => {
          alert("Oh no, something went wrong!");
        });
      })
  }
}
