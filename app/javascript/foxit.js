import * as UIExtension from '@foxitsoftware/foxit-pdf-sdk-for-web-library/lib/UIExtension.full.js';
import '@foxitsoftware/foxit-pdf-sdk-for-web-library/lib/UIExtension.vw.css';

window.pdfui = new UIExtension.PDFUI({
    viewerOptions: {
        libPath: 'node_modules/@foxitsoftware/foxit-pdf-sdk-for-web-library/lib',
        jr: {
            licenseKey: license.licenseKey,
            licenseSN: license.licenseSN,
            enginePath: './jr-engine/gsdk',
            fontPath: 'http://webpdf.foxitsoftware.com/webfonts/'
        }
    },
    renderTo: '#pdf-ui',
    addons: [
        'node_modules/@foxitsoftware/foxit-pdf-sdk-for-web-library/lib/uix-addons/path-objects'
    ]
});

console.log("FOXIT!!")
