(() => {
  function moveAddDishPanelLast() {
    const menu = document.getElementById('menu');
    const menuList = document.getElementById('menuList');
    if (!menu || !menuList) return;

    const addPanel = [...menu.querySelectorAll(':scope > .panel')].find(panel =>
      panel.querySelector('h3')?.textContent.trim() === 'Ajouter un plat'
    );
    if (!addPanel) return;

    menu.appendChild(addPanel);
    addPanel.style.marginTop = '18px';
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', moveAddDishPanelLast);
  } else {
    moveAddDishPanelLast();
  }

  document.querySelector('[data-tab="menu"]')?.addEventListener('click', () => {
    setTimeout(moveAddDishPanelLast, 0);
  });

  setTimeout(moveAddDishPanelLast, 800);
})();
