(() => {
  const SUPABASE_URL = 'https://ogyjqnbqvihqjikidrya.supabase.co';
  const SUPABASE_KEY = 'sb_publishable_Y5a2AS18uYJhzxh0-GYa0g_VWtSwgFz';

  function esc(v) {
    return String(v ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  }

  async function loadPublicMenu() {
    const grid = document.getElementById('menuGrid');
    const filters = document.getElementById('filters');
    if (!grid || !filters) return;

    try {
      const response = await fetch(`${SUPABASE_URL}/rest/v1/menu_items?select=*&is_available=eq.true&order=sort_order.asc,created_at.asc`, {
        headers: {
          apikey: SUPABASE_KEY,
          Authorization: `Bearer ${SUPABASE_KEY}`
        }
      });
      if (!response.ok) throw new Error(await response.text());
      const items = await response.json();
      if (!Array.isArray(items) || !items.length) return;

      const categories = ['Tout', ...new Set(items.map(x => x.category))];
      let selectedCategory = 'Tout';

      function renderFilters() {
        filters.innerHTML = categories.map(c => `<button class="filter ${c === selectedCategory ? 'active' : ''}" data-db-cat="${esc(c)}">${esc(c)}</button>`).join('');
        filters.querySelectorAll('[data-db-cat]').forEach(button => {
          button.addEventListener('click', () => {
            selectedCategory = button.dataset.dbCat;
            renderFilters();
            renderMenu();
          });
        });
      }

      function renderMenu() {
        const rows = selectedCategory === 'Tout' ? items : items.filter(x => x.category === selectedCategory);
        grid.innerHTML = rows.map(x => `<article class="dish"><div><h3>${esc(x.name)}</h3><p>${esc(x.description || '')}</p>${x.is_vegetarian ? '<span class="tag">🌿 Végétarien</span>' : ''}</div><div class="dish-price">${Number(x.price).toFixed(2).replace('.', ',')} €</div></article>`).join('');
      }

      renderFilters();
      renderMenu();
    } catch (error) {
      console.error('Menu Supabase error:', error);
    }
  }

  document.addEventListener('submit', async (event) => {
    const form = event.target;
    if (!(form instanceof HTMLFormElement) || form.id !== 'reservationForm') return;

    event.preventDefault();
    event.stopImmediatePropagation();

    const success = document.getElementById('success');
    const button = form.querySelector('button[type="submit"]');
    const data = Object.fromEntries(new FormData(form));

    const payload = {
      customer_name: String(data.name || '').trim(),
      phone: String(data.phone || '').trim(),
      reservation_date: String(data.date || ''),
      reservation_time: String(data.time || ''),
      guest_count: Number(data.guests || 1),
      message: String(data.message || '').trim(),
      status: 'pending'
    };

    if (button) {
      button.disabled = true;
      button.dataset.originalText = button.textContent || '';
      button.textContent = 'Envoi en cours…';
    }

    try {
      const response = await fetch(`${SUPABASE_URL}/rest/v1/reservations`, {
        method: 'POST',
        headers: {
          apikey: SUPABASE_KEY,
          Authorization: `Bearer ${SUPABASE_KEY}`,
          'Content-Type': 'application/json',
          Prefer: 'return=minimal'
        },
        body: JSON.stringify(payload)
      });

      if (!response.ok) {
        const details = await response.text();
        throw new Error(details || `HTTP ${response.status}`);
      }

      if (success) {
        success.style.display = 'block';
        success.style.background = 'rgba(47,138,87,.1)';
        success.style.color = '#206b42';
        success.textContent = '✅ Demande de réservation envoyée. Le restaurant la retrouvera dans son espace administrateur.';
      }
      form.reset();
      const dateInput = form.querySelector('input[type="date"]');
      if (dateInput) dateInput.min = new Date().toISOString().slice(0, 10);
      if (success) setTimeout(() => success.scrollIntoView({ behavior: 'smooth', block: 'center' }), 50);
    } catch (error) {
      console.error('Reservation Supabase error:', error);
      if (success) {
        success.style.display = 'block';
        success.style.background = '#fff0ee';
        success.style.color = '#a33e38';
        success.textContent = '❌ La réservation n’a pas pu être envoyée. Merci de réessayer ou d’appeler le restaurant.';
      }
    } finally {
      if (button) {
        button.disabled = false;
        button.textContent = button.dataset.originalText || 'Envoyer la demande de réservation';
      }
    }
  }, true);

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadPublicMenu);
  } else {
    loadPublicMenu();
  }
})();
