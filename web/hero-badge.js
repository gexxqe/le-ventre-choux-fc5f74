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
        border-radius:50%;
        overflow:hidden;
        box-shadow:0 18px 48px rgba(0,0,0,.28);
        border:4px solid rgba(255,255,255,.14);
        z-index:1;
      }
      .hero-restaurant-badge svg{display:block;width:100%;height:100%}
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

    const badge = document.createElement('div');
    badge.className = 'hero-restaurant-badge';
    badge.setAttribute('aria-label', 'Logo Le Ventre à Choux');
    badge.innerHTML = `
      <svg viewBox="0 0 420 420" role="img" aria-labelledby="badgeTitle" xmlns="http://www.w3.org/2000/svg">
        <title id="badgeTitle">Le Ventre à Choux</title>
        <circle cx="210" cy="210" r="208" fill="#102f25"/>
        <circle cx="210" cy="210" r="194" fill="none" stroke="#f6eddc" stroke-width="5"/>
        <circle cx="210" cy="210" r="182" fill="none" stroke="#f6eddc" stroke-width="2" opacity=".8"/>
        <text x="210" y="58" text-anchor="middle" fill="#f6eddc" font-family="Georgia,serif" font-size="20" letter-spacing="5">BAR · RESTAURANT</text>
        <text x="210" y="126" text-anchor="middle" fill="#f6eddc" font-family="Georgia,serif" font-size="52" font-weight="700">Le</text>
        <text x="210" y="211" text-anchor="middle" fill="#f6eddc" font-family="Georgia,serif" font-size="82" font-weight="700">Ventre</text>
        <text x="282" y="260" text-anchor="middle" fill="#f6eddc" font-family="Georgia,serif" font-size="46" font-weight="700">à</text>
        <text x="210" y="330" text-anchor="middle" fill="#f6eddc" font-family="Georgia,serif" font-size="74" font-weight="700">Choux</text>
        <g transform="translate(170 250)" fill="none" stroke="#f6eddc" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M40 44C13 41 1 23 9 8c13 1 25 7 31 19 6-12 18-18 31-19 8 15-4 33-31 36Z"/>
          <path d="M40 27c-10-10-19-12-28-10M40 27c10-10 19-12 28-10M40 27v22"/>
          <path d="M28 43c4-8 8-13 12-16 4 3 8 8 12 16"/>
        </g>
        <path d="M105 355h82M233 355h82" stroke="#f6eddc" stroke-width="3" stroke-linecap="round" opacity=".9"/>
      </svg>
    `;
    hero.appendChild(badge);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', installHeroBadge);
  } else {
    installHeroBadge();
  }
})();
