(() => {
  const DAILY_MENU_ID = 'a4caeb25-db08-4274-973b-6a8f57f5bc69';
  const DAILY_BUCKET = 'daily-menu';
  const DAILY_IMAGE_PATH = 'current.webp';

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

  function updateCropPreview() {
    const img = document.getElementById('dailyPreview');
    const x = document.getElementById('cropX');
    const y = document.getElementById('cropY');
    const z = document.getElementById('cropZoom');
    if (!img || !x || !y || !z) return;
    img.style.objectPosition = `${x.value}% ${y.value}%`;
    img.style.transform = `scale(${Number(z.value)})`;
    document.getElementById('cropXValue').textContent = `${x.value}%`;
    document.getElementById('cropYValue').textContent = `${y.value}%`;
    document.getElementById('cropZoomValue').textContent = `${Math.round(Number(z.value) * 100)}%`;
  }

  function ensureDailyMenuPanel() {
    const menuSection = document.getElementById('menu');
    const menuList = document.getElementById('menuList');
    if (!menuSection || !menuList || document.getElementById('dailyMenuPanel')) return;

    const panel = document.createElement('div');
    panel.id = 'dailyMenuPanel';
    panel.className = 'panel';
    panel.style.marginBottom = '18px';
    panel.innerHTML = `
      <h3 style="margin-top:0">Menu du jour — mise en avant</h3>
      <p class="small">Cette zone contrôle le grand bloc vert du site.</p>
      <div class="grid3">
        <div class="field"><label>Titre</label><input id="dailyTitle"></div>
        <div class="field"><label>Prix (€)</label><input id="dailyPrice" type="number" min="0" step="0.10"></div>
        <div class="field"><label>Photo du jour</label><input id="dailyPhoto" type="file" accept="image/jpeg,image/png,image/webp"></div>
      </div>
      <div class="field"><label>Description</label><textarea id="dailyDescription" rows="3"></textarea></div>
      <div style="display:grid;grid-template-columns:minmax(260px,390px) 1fr;gap:18px;align-items:start;margin-top:14px">
        <div>
          <div id="dailyPreviewFrame" style="width:100%;aspect-ratio:1.95/1;overflow:hidden;border-radius:16px;border:1px solid var(--line);background:#eef1ed;position:relative">
            <img id="dailyPreview" alt="Aperçu du menu du jour" style="display:none;width:100%;height:100%;object-fit:cover;object-position:50% 50%;transform:scale(1);transform-origin:center;transition:transform .12s ease">
          </div>
          <div id="dailyNoPhoto" class="small" style="margin-top:7px">Aucune photo chargée pour le moment.</div>
          <div id="cropControls" style="display:none;margin-top:14px;padding:14px;border:1px solid var(--line);border-radius:14px;background:#fff">
            <strong style="display:block;margin-bottom:10px">Cadrage de la photo</strong>
            <div class="field"><label>Gauche ↔ droite <span id="cropXValue">50%</span></label><input id="cropX" type="range" min="0" max="100" value="50"></div>
            <div class="field"><label>Haut ↕ bas <span id="cropYValue">50%</span></label><input id="cropY" type="range" min="0" max="100" value="50"></div>
            <div class="field"><label>Zoom <span id="cropZoomValue">100%</span></label><input id="cropZoom" type="range" min="1" max="2" step="0.05" value="1"></div>
            <p class="small" style="margin-bottom:0">Le cadrage visible ici sera enregistré sur le site.</p>
          </div>
        </div>
        <div>
          <div class="actions" style="margin-top:0">
            <button id="saveDailyMenu" class="btn primary">Enregistrer le menu du jour</button>
            <button id="removeDailyPhoto" class="btn danger">Supprimer la photo</button>
          </div>
          <div id="dailyMenuMsg" class="small" style="margin-top:10px"></div>
        </div>
      </div>`;
    menuSection.insertBefore(panel, menuList);

    document.getElementById('saveDailyMenu').onclick = saveDailyMenu;
    document.getElementById('removeDailyPhoto').onclick = removeDailyPhoto;
    ['cropX','cropY','cropZoom'].forEach(id => document.getElementById(id).addEventListener('input', updateCropPreview));

    document.getElementById('dailyPhoto').addEventListener('change', e => {
      const file = e.target.files?.[0];
      if (!file) return;
      const preview = document.getElementById('dailyPreview');
      document.getElementById('cropX').value = '50';
      document.getElementById('cropY').value = '50';
      document.getElementById('cropZoom').value = '1';
      preview.src = URL.createObjectURL(file);
      preview.style.display = 'block';
      document.getElementById('dailyNoPhoto').style.display = 'none';
      document.getElementById('cropControls').style.display = 'block';
      updateCropPreview();
    });
  }

  function dailyPublicUrl(cacheBust = true) {
    const { data } = db.storage.from(DAILY_BUCKET).getPublicUrl(DAILY_IMAGE_PATH);
    return data.publicUrl + (cacheBust ? `?v=${Date.now()}` : '');
  }

  async function loadDailyMenuEditor() {
    ensureDailyMenuPanel();
    const title = document.getElementById('dailyTitle');
    if (!title) return;
    const { data, error } = await db.from('menu_items').select('*').eq('id', DAILY_MENU_ID).single();
    const msg = document.getElementById('dailyMenuMsg');
    if (error) {
      msg.className = 'error';
      msg.textContent = error.message;
      return;
    }
    title.value = data.name || '';
    document.getElementById('dailyDescription').value = data.description || '';
    document.getElementById('dailyPrice').value = Number(data.price).toFixed(2);
    const preview = document.getElementById('dailyPreview');
    const noPhoto = document.getElementById('dailyNoPhoto');
    preview.onload = () => {
      preview.style.display = 'block';
      preview.style.objectPosition = '50% 50%';
      preview.style.transform = 'scale(1)';
      noPhoto.style.display = 'none';
    };
    preview.onerror = () => { preview.style.display = 'none'; noPhoto.style.display = 'block'; };
    preview.src = dailyPublicUrl();
  }

  async function imageToWebp(file) {
    const bitmap = await createImageBitmap(file);
    const targetW = 1400;
    const targetH = 720;
    const targetAspect = targetW / targetH;
    const imageAspect = bitmap.width / bitmap.height;
    let baseW, baseH;
    if (imageAspect > targetAspect) {
      baseH = bitmap.height;
      baseW = baseH * targetAspect;
    } else {
      baseW = bitmap.width;
      baseH = baseW / targetAspect;
    }

    const zoom = Number(document.getElementById('cropZoom')?.value || 1);
    const posX = Number(document.getElementById('cropX')?.value || 50) / 100;
    const posY = Number(document.getElementById('cropY')?.value || 50) / 100;
    const cropW = baseW / zoom;
    const cropH = baseH / zoom;
    const sx = (bitmap.width - cropW) * posX;
    const sy = (bitmap.height - cropH) * posY;

    const canvas = document.createElement('canvas');
    canvas.width = targetW;
    canvas.height = targetH;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(bitmap, sx, sy, cropW, cropH, 0, 0, targetW, targetH);
    bitmap.close?.();
    return await new Promise((resolve, reject) => {
      canvas.toBlob(blob => blob ? resolve(blob) : reject(new Error('Impossible de préparer la photo.')), 'image/webp', 0.88);
    });
  }

  async function saveDailyMenu() {
    const button = document.getElementById('saveDailyMenu');
    const msg = document.getElementById('dailyMenuMsg');
    const original = button.textContent;
    button.disabled = true;
    button.textContent = 'Enregistrement…';
    msg.className = 'small';
    msg.textContent = '';
    try {
      const name = document.getElementById('dailyTitle').value.trim();
      const description = document.getElementById('dailyDescription').value.trim();
      const price = Number(document.getElementById('dailyPrice').value);
      if (!name || !Number.isFinite(price) || price < 0) throw new Error('Titre ou prix invalide.');
      const { error: updateError } = await db.from('menu_items').update({
        name,
        description,
        price,
        is_available: true,
        updated_at: new Date().toISOString()
      }).eq('id', DAILY_MENU_ID);
      if (updateError) throw updateError;

      const file = document.getElementById('dailyPhoto').files?.[0];
      if (file) {
        if (file.size > 12 * 1024 * 1024) throw new Error('La photo est trop grande. Maximum 12 Mo avant compression.');
        const webp = await imageToWebp(file);
        const { error: uploadError } = await db.storage.from(DAILY_BUCKET).upload(DAILY_IMAGE_PATH, webp, {
          contentType: 'image/webp',
          upsert: true,
          cacheControl: '60'
        });
        if (uploadError) throw uploadError;
        document.getElementById('dailyPhoto').value = '';
        document.getElementById('cropControls').style.display = 'none';
      }

      msg.className = 'ok';
      msg.textContent = 'Menu du jour enregistré ✅';
      await loadDailyMenuEditor();
      await loadMenu();
    } catch (error) {
      msg.className = 'error';
      msg.textContent = error?.message || String(error);
    } finally {
      button.disabled = false;
      button.textContent = original;
    }
  }

  async function removeDailyPhoto() {
    if (!confirm('Supprimer la photo du menu du jour ?')) return;
    const msg = document.getElementById('dailyMenuMsg');
    const { error } = await db.storage.from(DAILY_BUCKET).remove([DAILY_IMAGE_PATH]);
    if (error) {
      msg.className = 'error';
      msg.textContent = error.message;
      return;
    }
    msg.className = 'ok';
    msg.textContent = 'Photo supprimée ✅';
    const preview = document.getElementById('dailyPreview');
    preview.style.display = 'none';
    document.getElementById('cropControls').style.display = 'none';
    document.getElementById('dailyNoPhoto').style.display = 'block';
  }

  const target = document.getElementById('menuList');
  if (target) {
    new MutationObserver(repairDeleteButtons).observe(target, { childList: true, subtree: true });
    repairDeleteButtons();
  }

  wireHoursSave();
  ensureDailyMenuPanel();
  document.querySelector('[data-tab="menu"]')?.addEventListener('click', () => setTimeout(loadDailyMenuEditor, 0));
  setTimeout(async () => {
    const { data: { session } } = await db.auth.getSession();
    if (session) loadDailyMenuEditor();
  }, 700);
})();