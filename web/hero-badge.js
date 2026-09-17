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
        box-shadow:0 18px 48px rgba(0,0,0,.28);
        z-index:1;
        overflow:hidden;
      }
      .hero-restaurant-badge svg{width:100%;height:100%;display:block}
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
    badge.setAttribute('role','img');
    badge.setAttribute('aria-label','Logo Le Ventre à Choux');
    badge.innerHTML = `
      <svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <defs>
          <path id="topArc" d="M 95 220 A 165 165 0 0 1 405 220"/>
          <filter id="grain"><feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="4" result="n"/><feBlend in="SourceGraphic" in2="n" mode="soft-light"/></filter>
        </defs>
        <circle cx="250" cy="250" r="246" fill="#17372c"/>
        <circle cx="250" cy="250" r="233" fill="none" stroke="#f3ead2" stroke-width="5"/>
        <circle cx="250" cy="250" r="220" fill="none" stroke="#f3ead2" stroke-width="2"/>
        <text fill="#f3ead2" font-family="Georgia, 'Times New Roman', serif" font-size="24" letter-spacing="5">
          <textPath href="#topArc" startOffset="50%" text-anchor="middle">• BAR – RESTAURANT •</textPath>
        </text>
        <text x="250" y="158" text-anchor="middle" fill="#f3ead2" font-family="Georgia, 'Times New Roman', serif" font-size="60" font-weight="700">Le</text>
        <text x="250" y="245" text-anchor="middle" fill="#f3ead2" font-family="Georgia, 'Times New Roman', serif" font-size="92" font-weight="700">Ventre</text>
        <text x="365" y="302" text-anchor="middle" fill="#f3ead2" font-family="Georgia, 'Times New Roman', serif" font-size="58" font-weight="700">à</text>
        <text x="250" y="382" text-anchor="middle" fill="#f3ead2" font-family="Georgia, 'Times New Roman', serif" font-size="88" font-weight="700">Ch   ux</text>
        <g transform="translate(250 332)" fill="none" stroke="#f3ead2" stroke-width="5" stroke-linecap="round" stroke-linejoin="round">
          <ellipse cx="0" cy="0" rx="50" ry="44"/>
          <path d="M-42 8 C-58 -5 -54 -30 -30 -42 C-15 -52 0 -44 0 -28 C0 -44 17 -54 32 -42 C55 -25 57 -3 42 10"/>
          <path d="M-30 22 C-42 8 -35 -14 -18 -27 C-8 -35 0 -24 0 -10 C0 -26 10 -35 20 -26 C36 -13 41 9 30 22"/>
          <path d="M0 -10 C-12 0 -14 18 0 34 C14 18 12 0 0 -10"/>
          <path d="M-48 0 C-28 6 -22 24 -22 38 M48 0 C28 6 22 24 22 38"/>
        </g>
        <path d="M115 420 H205 M295 420 H385" stroke="#f3ead2" stroke-width="4" stroke-linecap="round"/>
        <path d="M250 420 C240 405 228 402 218 406 C227 418 239 425 250 432 C261 425 273 418 282 406 C272 402 260 405 250 420Z" fill="none" stroke="#f3ead2" stroke-width="4"/>
      </svg>`;
    hero.appendChild(badge);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', installHeroBadge);
  else installHeroBadge();
})();
