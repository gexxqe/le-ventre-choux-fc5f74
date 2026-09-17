(() => {
  function applyHeroLogo() {
    const hero = document.querySelector('.hero-card');
    if (!hero || hero.querySelector('.hero-logo-image')) return;

    hero.style.position = 'relative';

    const img = document.createElement('img');
    img.className = 'hero-logo-image';
    img.src = './assets/hero-logo.jpg?v=20260917-1';
    img.alt = 'Le Ventre à Choux';
    img.style.cssText = [
      'position:absolute',
      'right:38px',
      'top:38px',
      'width:min(34%,360px)',
      'max-height:360px',
      'height:auto',
      'object-fit:contain',
      'border-radius:24px',
      'box-shadow:0 18px 44px rgba(0,0,0,.28)',
      'z-index:1'
    ].join(';');

    const style = document.createElement('style');
    style.textContent = `
      .hero-card::after{display:none!important}
      .hero-copy{max-width:58%!important;z-index:2!important}
      @media(max-width:800px){
        .hero-card{padding-top:250px!important}
        .hero-logo-image{top:22px!important;right:22px!important;left:22px!important;width:auto!important;max-width:none!important;max-height:210px!important;margin:auto!important}
        .hero-copy{max-width:100%!important}
      }
    `;
    document.head.appendChild(style);
    hero.appendChild(img);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', applyHeroLogo);
  else applyHeroLogo();
})();
