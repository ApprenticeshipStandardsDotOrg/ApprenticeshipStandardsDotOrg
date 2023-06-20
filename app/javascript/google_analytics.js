document.addEventListener('turbo:load', function(event) {
  if (typeof gtag === 'function') {
    gtag('config', 'G-EJH1K3YRJK', {
      'page_title': document.title,
      'page_path': location.href.replace(location.origin, ""),
    })
  }
})
