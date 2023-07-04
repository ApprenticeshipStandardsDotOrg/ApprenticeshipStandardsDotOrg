import * as UIExtension from './@foxitsoftware/foxit-pdf-sdk-for-web-library-full/lib/UIExtension.full.js';

const pdfui = new UIExtension.PDFUI({
    viewerOptions: {
        libPath: './@foxitsoftware/foxit-pdf-sdk-for-web-library-full/lib',
        jr: {
            licenseKey: "PjwcmTaQOSysb7uJGyG8Al57Uht9GSJjsYgfy44/NjsK5BbyOT5ekCZEFpkGn8Y+uFx59ICYT71nWvfXRlMpYaPlCWs8jLiF4q+3PBj4/CDpDPiJLukD63ZNAlDoRltq1ZWRPxt8+WPav4cZyzTHKG2YF78GFMQTXCwxtL3SfkNCthNCnCCnl8uzxK+M6mkkoX3NwcpwS7B/W66lILB/xeS9MZAO9WNVuuDFeXnIoPOUyQYXaXkCF/IqiO8Q9FNqPMLDLDCLCRSPGBD/ONy3W2m4C1fyYmml94cQpsZPAdRot0UrWsFUGpqhyhE6KelA9XF9+jsxbex/9oDFe/H3zSKtV6Q1pQfaCaoeN66HWtuxIiqYVI/6Nz4nhsKU5nhAdN/RitPFoW9E1zofje3qSOneg4pkXYXpjXbBuP5GnK0YzV55ZF96U4UMavtP43PIuTKdtRmzXwfFlyRUf3dfpqVCfAENoRsHULJIeDqKgYFk2o3coERrjZizx0VUPUd4ZwY9k6wWeH2og0QYYOoY5do7r4iMbnp+fIsZ1BEiJdjsQvhRoNQ0Q9KKtpZ3iTjiP8JdJA+trLDNj22GnYQCb+rpXAsSytEYsW9NRGqNwvZkRHomWElbYLCAWnadmubOO5lTQD7hWcREgcwsjDkLrf3pwl/empXMsRa4QHUfyxIb+qv9qlRmqEo4Qet7zXfMiw81uKr7rgDV4xq033bA4kyck4TPrjyksA5oqlWt7ApFtTH63hFywUjZbyJXnDdtSfK4NDsmqsaeUGz8jrLl+hcXuxkmBrgWBIZkhVyjl2pdU/vyT4cN9jvKXjryyLw2vsi4c9KaYtyG05ylcTlukO8ahG0N+y+ri1icJVB5fexk/NQqpBIvHujxsbt6KMwQ4hBVGmz6tWkEshpSdthL+nhq9QYqA5Ny7tP7YCqTK5kTBidi9ZjotWg6X9qY7HCIgFuyjsNnOwVkIQdaedIlCJX7tr/x3vTQrMIZDgGUeS2PZmbDQFTp5rQBVjBsNjpx8GBsDcqW4w58JY2iBGbVDY75O/XFYwAXxX1McmsGx2+8h0FOcxc/CM8BYVbdOsl7vMBLgwy9DzkdVzocenyxVjpwh2KcsYbiRiMgNmV318Wwk6boVfkZ57jK+3n6WxOqMNeyUwAr3lv+JpuPaGpWpqt/Q1kWta/JaD4iluZE6Vm7xcmngdi81O99jrZdrst7iE1W7BCTUJ7j3uAlDnXRWxdviw6UjoRY",
            licenseSN: "jUfblxjDiouL0eyJAFfwklxkmcN1rB3m4p5GRhGcsejbhKwOiV0I5w==",
            enginePath: './@foxitsoftware/foxit-pdf-sdk-for-web-library-full/lib/jr-engine/gsdk',
            fontPath: 'http://webpdf.foxitsoftware.com/webfonts/'
        }
    },
    renderTo: '#pdf-ui',
});
