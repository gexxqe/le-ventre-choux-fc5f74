(() => {
  function installHeroBadge() {
    const hero = document.querySelector('.hero-card');
    if (!hero || hero.querySelector('.hero-restaurant-badge')) return;

    const style = document.createElement('style');
    style.textContent = `
      .hero-card::after{display:none!important}
      .hero-copy{max-width:58%!important;position:relative;z-index:2!important}
      .hero-restaurant-badge{
        position:absolute;
        right:52px;
        top:50%;
        transform:translateY(-50%);
        width:min(32vw,330px);
        aspect-ratio:1/1;
        object-fit:cover;
        border-radius:50%;
        box-shadow:0 18px 48px rgba(0,0,0,.28);
        border:4px solid rgba(255,255,255,.14);
        z-index:1;
      }
      @media(max-width:800px){
        .hero-card{padding-top:300px!important}
        .hero-copy{max-width:100%!important}
        .hero-restaurant-badge{
          top:26px;
          left:50%;
          right:auto;
          transform:translateX(-50%);
          width:min(62vw,230px);
        }
      }
    `;
    document.head.appendChild(style);

    const img = document.createElement('img');
    img.className = 'hero-restaurant-badge';
    img.src = './assets/logo-badge.webp?v=20260917-3';
    img.alt = 'Logo Le Ventre à Choux';
    hero.appendChild(img);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', installHeroBadge);
  } else {
    installHeroBadge();
  }
})();
