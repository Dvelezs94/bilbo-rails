if (navigator.serviceWorker) {
  navigator.serviceWorker.register('/serviceworker.js', { scope: './' })
    .then(function(reg) {
      console.log('[Companion]', 'Service worker registered!');
    });

    self.addEventListener('install', function() {
      console.log('Install!');
    });
    self.addEventListener("activate", event => {
      console.log('Activate!');
    });
    self.addEventListener('fetch', function(event) {
      console.log('Fetch!', event.request);
    });
}
