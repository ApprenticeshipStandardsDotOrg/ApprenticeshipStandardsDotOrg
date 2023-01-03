document.addEventListener('turbolinks:load', function(event) {
  if (typeof gtag === 'function') {
    gtag('config', 'G-EJH1K3YRJK', {
      'page_location': event.data.url
    })
  }
})