(function () {
  'use strict';
  var btn = document.querySelector('.nav-toggle');
  var nav = document.querySelector('.site-nav');
  if (!btn || !nav) return;

  btn.addEventListener('click', function () {
    var open = btn.getAttribute('aria-expanded') === 'true';
    btn.setAttribute('aria-expanded', String(!open));
    nav.classList.toggle('is-open');
  });

  // Close nav when a link is clicked (mobile)
  nav.querySelectorAll('a').forEach(function (link) {
    link.addEventListener('click', function () {
      btn.setAttribute('aria-expanded', 'false');
      nav.classList.remove('is-open');
    });
  });
})();
