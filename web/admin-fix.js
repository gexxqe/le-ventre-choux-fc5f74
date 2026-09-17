(() => {
  function repairDeleteButtons() {
    document.querySelectorAll('#menuList .row').forEach(row => {
      const saveButton = row.querySelector('button[onclick^="saveDish("]');
      const deleteButton = row.querySelector('button.danger');
      if (!saveButton || !deleteButton) return;

      const match = (saveButton.getAttribute('onclick') || '').match(/saveDish\('([^']+)'\)/);
      if (!match) return;
      const id = match[1];

      deleteButton.removeAttribute('onclick');
      deleteButton.onclick = async () => {
        if (!confirm('Supprimer ce plat de la carte ?')) return;
        const { error } = await db.from('menu_items').delete().eq('id', id);
        if (error) alert(error.message);
        else loadMenu();
      };
    });
  }

  const target = document.getElementById('menuList');
  if (target) {
    new MutationObserver(repairDeleteButtons).observe(target, { childList: true, subtree: true });
    repairDeleteButtons();
  }
})();
