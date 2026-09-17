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

  function parseSlot(value) {
    const text = String(value || '').trim();
    if (!text) return { start: null, end: null, closed: false };
    if (/^ferm[eé]$/i.test(text)) return { start: null, end: null, closed: true };

    const normalized = text.replace(/[–—]/g, '-').replace(/\s+/g, '');
    const match = normalized.match(/^(\d{1,2}:\d{2})-(\d{1,2}:\d{2})$/);
    if (!match) throw new Error(`Format invalide : ${text}. Utilise par exemple 12:00-14:00 ou Fermé.`);

    const validTime = t => {
      const [h, m] = t.split(':').map(Number);
      return h >= 0 && h <= 23 && m >= 0 && m <= 59;
    };
    if (!validTime(match[1]) || !validTime(match[2])) throw new Error(`Heure invalide : ${text}`);
    return { start: match[1].padStart(5, '0'), end: match[2].padStart(5, '0'), closed: false };
  }

  function wireHoursSave() {
    const button = document.getElementById('saveHours');
    if (!button) return;

    button.onclick = async () => {
      const original = button.textContent;
      button.disabled = true;
      button.textContent = 'Enregistrement…';

      try {
        for (let i = 0; i < 7; i++) {
          const lunchInput = document.getElementById('hl_' + i);
          const dinnerInput = document.getElementById('hd_' + i);
          if (!lunchInput || !dinnerInput) continue;

          const lunch = parseSlot(lunchInput.value);
          const dinner = parseSlot(dinnerInput.value);
          const fullyClosed = lunch.closed && dinner.closed;

          const payload = {
            is_closed: fullyClosed,
            lunch_start: lunch.closed ? null : lunch.start,
            lunch_end: lunch.closed ? null : lunch.end,
            dinner_start: dinner.closed ? null : dinner.start,
            dinner_end: dinner.closed ? null : dinner.end
          };

          const { error } = await db.from('opening_hours').update(payload).eq('day_index', i);
          if (error) throw new Error(`${lunchInput.closest('.row')?.querySelector('b')?.textContent || 'Jour ' + i}: ${error.message}`);
        }

        alert('Horaires enregistrés ✅');
        await loadHours();
      } catch (error) {
        alert('Erreur lors de l’enregistrement : ' + (error?.message || error));
      } finally {
        button.disabled = false;
        button.textContent = original;
      }
    };
  }

  const target = document.getElementById('menuList');
  if (target) {
    new MutationObserver(repairDeleteButtons).observe(target, { childList: true, subtree: true });
    repairDeleteButtons();
  }

  wireHoursSave();
})();
