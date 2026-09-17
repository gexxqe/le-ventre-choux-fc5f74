(() => {
  const SUPABASE_URL = 'https://ogyjqnbqvihqjikidrya.supabase.co';
  const SUPABASE_KEY = 'sb_publishable_Y5a2AS18uYJhzxh0-GYa0g_VWtSwgFz';
  const headers = { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` };

  const money = value => `${Number(value).toFixed(2).replace('.', ',')} €`;

  async function syncDailySpecial() {
    try {
      const r = await fetch(`${SUPABASE_URL}/rest/v1/menu_items?select=name,description,price&is_available=eq.true&is_daily_special=eq.true&limit=1`, { headers });
      if (!r.ok) return;
      const [item] = await r.json();
      if (!item) return;
      const box = document.querySelector('.special');
      if (!box) return;
      const title = box.querySelector('h3');
      const text = box.querySelector('p');
      const price = box.querySelector('.price');
      if (title) title.textContent = item.name;
      if (text) text.textContent = item.description || 'Menu du jour proposé le midi.';
      if (price) price.textContent = money(item.price);
    } catch (e) {
      console.error('Daily special sync error', e);
    }
  }

  function minutesToTime(total) {
    const h = String(Math.floor(total / 60)).padStart(2, '0');
    const m = String(total % 60).padStart(2, '0');
    return `${h}:${m}`;
  }

  function timeToMinutes(value) {
    if (!value) return null;
    const [h, m] = String(value).split(':').map(Number);
    return h * 60 + m;
  }

  async function syncReservationTimes() {
    const dateInput = document.querySelector('#reservationForm input[name="date"]');
    const timeSelect = document.querySelector('#reservationForm select[name="time"]');
    if (!dateInput || !timeSelect) return;

    try {
      const r = await fetch(`${SUPABASE_URL}/rest/v1/opening_hours?select=*&order=day_index.asc`, { headers });
      if (!r.ok) return;
      const hours = await r.json();

      const refresh = () => {
        if (!dateInput.value) return;
        const d = new Date(`${dateInput.value}T12:00:00`);
        const dayIndex = (d.getDay() + 6) % 7;
        const row = hours.find(x => Number(x.day_index) === dayIndex);
        const slots = [];

        if (row && !row.is_closed) {
          const ranges = [
            [row.lunch_start, row.lunch_end],
            [row.dinner_start, row.dinner_end]
          ];
          for (const [start, end] of ranges) {
            const s = timeToMinutes(start);
            const e = timeToMinutes(end);
            if (s === null || e === null) continue;
            for (let t = s; t < e; t += 30) slots.push(minutesToTime(t));
          }
        }

        if (!slots.length) {
          timeSelect.innerHTML = '<option value="">Fermé ce jour</option>';
          timeSelect.disabled = true;
        } else {
          timeSelect.disabled = false;
          timeSelect.innerHTML = slots.map(t => `<option value="${t}">${t}</option>`).join('');
        }
      };

      dateInput.addEventListener('change', refresh);
      if (dateInput.value) refresh();
    } catch (e) {
      console.error('Reservation times sync error', e);
    }
  }

  const boot = () => Promise.all([syncDailySpecial(), syncReservationTimes()]);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();
})();
