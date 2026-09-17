(() => {
  const SUPABASE_URL = 'https://ogyjqnbqvihqjikidrya.supabase.co';
  const SUPABASE_KEY = 'sb_publishable_Y5a2AS18uYJhzxh0-GYa0g_VWtSwgFz';

  function esc(v) {
    return String(v ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  }

  const apiHeaders = {
    apikey: SUPABASE_KEY,
    Authorization: `Bearer ${SUPABASE_KEY}`
  };

  async function loadPublicMenu() {
    const grid = document.getElementById('menuGrid');
    const filters = document.getElementById('filters');
    if (!grid || !filters) return;

    try {
      const response = await fetch(`${SUPABASE_URL}/rest/v1/menu_items?select=*&is_available=eq.true&order=sort_order.asc,created_at.asc`, { headers: apiHeaders });
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

  function toMinutes(value) {
    if (!value) return null;
    const [h, m] = String(value).split(':').map(Number);
    return h * 60 + m;
  }

  async function loadPublicHours() {
    const container = document.getElementById('hours');
    const statusTitle = document.getElementById('statusTitle');
    const statusDetail = document.getElementById('statusDetail');
    const statusDot = document.getElementById('statusDot');
    if (!container) return;

    try {
      const response = await fetch(`${SUPABASE_URL}/rest/v1/opening_hours?select=*&order=day_index.asc`, { headers: apiHeaders });
      if (!response.ok) throw new Error(await response.text());
      const rows = await response.json();
      if (!Array.isArray(rows) || rows.length !== 7) return;

      const labelFor = row => {
        if (row.is_closed) return 'Fermé';
        const parts = [];
        if (row.lunch_start && row.lunch_end) parts.push(`${row.lunch_start}–${row.lunch_end}`);
        if (row.dinner_start && row.dinner_end) parts.push(`${row.dinner_start}–${row.dinner_end}`);
        return parts.length ? parts.join(' • ') : 'Fermé';
      };

      container.innerHTML = rows.map(row => `<div class="hour"><strong>${esc(row.day_name)}</strong><span>${esc(labelFor(row))}</span></div>`).join('');

      const now = new Date();
      const dayIndex = (now.getDay() + 6) % 7;
      const row = rows.find(x => Number(x.day_index) === dayIndex);
      if (!row || !statusTitle || !statusDetail || !statusDot) return;

      const current = now.getHours() * 60 + now.getMinutes();
      const lunchStart = toMinutes(row.lunch_start);
      const lunchEnd = toMinutes(row.lunch_end);
      const dinnerStart = toMinutes(row.dinner_start);
      const dinnerEnd = toMinutes(row.dinner_end);
      const lunchOpen = lunchStart !== null && lunchEnd !== null && current >= lunchStart && current < lunchEnd;
      const dinnerOpen = dinnerStart !== null && dinnerEnd !== null && current >= dinnerStart && current < dinnerEnd;
      const open = !row.is_closed && (lunchOpen || dinnerOpen);

      let detail = 'Fermé aujourd’hui';
      if (!row.is_closed) {
        if (lunchOpen) detail = `Service du midi jusqu’à ${row.lunch_end}`;
        else if (dinnerOpen) detail = `Service du soir jusqu’à ${row.dinner_end}`;
        else if (lunchStart !== null && current < lunchStart) detail = `Ouvre à ${row.lunch_start} pour le déjeuner`;
        else if (dinnerStart !== null && current < dinnerStart) detail = `Ouvre à ${row.dinner_start} pour le dîner`;
        else detail = 'Fermé pour la nuit';
      }

      statusTitle.textContent = open ? 'Ouvert maintenant' : 'Fermé';
      statusDetail.textContent = detail;
      statusDot.style.background = open ? 'var(--ok)' : '#b64b42';
    } catch (error) {
      console.error('Opening hours Supabase error:', error);
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
          ...apiHeaders,
          'Content-Type': 'application/json',
          Prefer: 'return=minimal'
        },
        body: JSON.stringify(payload)
      });

      if (!response.ok) throw new Error(await response.text());

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

  const boot = () => Promise.all([loadPublicMenu(), loadPublicHours()]);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();
})();
