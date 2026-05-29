(function () {
  function initializeAdminFlowbite() {
    if (typeof window.initFlowbite === "function") {
      window.initFlowbite();
      return;
    }

    if (typeof window.initDropdowns === "function") {
      window.initDropdowns();
    }
  }

  document.addEventListener("DOMContentLoaded", initializeAdminFlowbite);
  document.addEventListener("turbo:load", initializeAdminFlowbite);
  document.addEventListener("turbo:render", initializeAdminFlowbite);
  document.addEventListener("turbo:frame-load", initializeAdminFlowbite);
})();
