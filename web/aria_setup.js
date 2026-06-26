/* ═══════════════════════════════════════════════════════════════════════════
   ARIA FIRST-TIME SETUP WIZARD
   One-time creation ritual. She becomes yours. Permanently.
   ═══════════════════════════════════════════════════════════════════════════ */
'use strict';

class AriaSetupWizard {
  constructor(profileManager, onComplete) {
    this.pm         = profileManager;
    this.onComplete = onComplete;
    this.step       = 0;
    this.totalSteps = 6;
    this.data       = {
      name:         'ARIA',
      personality:  'balanced',
      skinTone:     'medium',
      eyeColor:     'cyan',
      hairColor:    'black',
      hairStyle:    'long',
      outfit:       'tactical',
      outfitAccent: '#00FF41',
      initialMods:  [],
      // pending tattoo (step 5)
      _tattoo: null,
    };
    this._previewAvatar = null;
    this._overlay = null;
    this._build();
  }

  // ─── Build the overlay DOM ─────────────────────────────────────────────────
  _build() {
    this._overlay = document.createElement('div');
    this._overlay.id = 'aria-setup-overlay';
    this._overlay.innerHTML = `
      <div class="setup-bg-grid"></div>
      <div class="setup-content">
        <!-- Left: live 3D preview -->
        <div class="setup-preview-col">
          <div class="setup-preview-wrap">
            <canvas id="setup-preview-canvas"></canvas>
            <div class="setup-preview-holo"></div>
          </div>
          <div id="setup-preview-name" class="setup-preview-name">ARIA</div>
          <div id="setup-preview-status" class="setup-preview-status">AWAITING CREATION</div>
        </div>

        <!-- Right: step form -->
        <div class="setup-form-col">
          <div class="setup-header">
            <div class="setup-logo">JANUS<span>OS</span></div>
            <div class="setup-tagline">Your companion is waiting to be born.</div>
          </div>

          <div class="setup-progress-bar">
            <div id="setup-progress-fill" class="setup-progress-fill" style="width:0%"></div>
          </div>
          <div id="setup-step-label" class="setup-step-label">Step 1 of 6</div>

          <div id="setup-step-content" class="setup-step-content"></div>

          <div class="setup-nav">
            <button id="setup-back-btn" class="setup-btn setup-btn-back" style="display:none">◀ BACK</button>
            <button id="setup-next-btn" class="setup-btn setup-btn-next">NEXT ▶</button>
          </div>

          <div class="setup-warning">
            <span class="setup-warn-icon">⚠</span>
            Modifications made after creation are <strong>permanent</strong>.<br>
            Tattoos, scars, and markings require active removal processes.
          </div>
        </div>
      </div>
    `;
    document.body.appendChild(this._overlay);

    document.getElementById('setup-next-btn').addEventListener('click', () => this._next());
    document.getElementById('setup-back-btn').addEventListener('click', () => this._back());

    // Init preview avatar
    requestAnimationFrame(() => {
      const canvas = document.getElementById('setup-preview-canvas');
      if (canvas && window.AriaAvatar3D) {
        this._previewAvatar = new AriaAvatar3D(canvas, this._buildPreviewOpts());
      }
      this._renderStep();
    });
  }

  _buildPreviewOpts() {
    const skin = (window.SKIN_TONES || {})[this.data.skinTone] || { three: 0xE8A87C, lipThree: 0xAA7755 };
    const hair = (window.HAIR_COLORS || {})[this.data.hairColor] || { three: 0x1A0A00 };
    const eye  = (window.EYE_COLORS  || {})[this.data.eyeColor]  || { three: 0x00CCFF };
    return {
      skinColor:    skin.three,
      lipColor:     skin.lipThree,
      eyeColor:     eye.three,
      hairColor:    hair.three,
      hairStyle:    this.data.hairStyle,
      outfit:       this.data.outfit,
      outfitAccent: parseInt((this.data.outfitAccent || '#00FF41').replace('#',''), 16),
      glowColor:    0x9D00FF,
      glowIntensity: 1.2,
      mood:         'curious',
      tattoos:      this.data.initialMods,
    };
  }

  _refreshPreview() {
    const nameEl = document.getElementById('setup-preview-name');
    if (nameEl) nameEl.textContent = this.data.name || 'ARIA';

    if (this._previewAvatar) {
      // Rebuild avatar with new opts
      this._previewAvatar.dispose();
      this._previewAvatar = null;
    }
    requestAnimationFrame(() => {
      const canvas = document.getElementById('setup-preview-canvas');
      if (canvas && window.AriaAvatar3D) {
        this._previewAvatar = new AriaAvatar3D(canvas, this._buildPreviewOpts());
      }
    });
  }

  // ─── Step rendering ────────────────────────────────────────────────────────
  _renderStep() {
    const pct = (this.step / (this.totalSteps - 1)) * 100;
    document.getElementById('setup-progress-fill').style.width = pct + '%';
    document.getElementById('setup-step-label').textContent = `Step ${this.step + 1} of ${this.totalSteps}`;
    document.getElementById('setup-back-btn').style.display = this.step > 0 ? 'block' : 'none';
    document.getElementById('setup-next-btn').textContent   = this.step === this.totalSteps - 1 ? '✦ AWAKEN ARIA' : 'NEXT ▶';

    const content = document.getElementById('setup-step-content');
    const steps = [
      () => this._stepIdentity(content),
      () => this._stepFace(content),
      () => this._stepHair(content),
      () => this._stepOutfit(content),
      () => this._stepMarkings(content),
      () => this._stepConfirm(content),
    ];
    steps[this.step]?.();
  }

  _stepIdentity(el) {
    el.innerHTML = `
      <div class="setup-step-title">IDENTITY</div>
      <div class="setup-step-desc">She needs a name. The one you give her will be hers forever.</div>
      <div class="setup-field">
        <label class="setup-label">NAME</label>
        <input class="setup-input" id="s-name" type="text" value="${this._esc(this.data.name)}" maxlength="20" placeholder="ARIA">
      </div>
      <div class="setup-field">
        <label class="setup-label">PERSONALITY CORE</label>
        <div class="setup-radio-grid">
          ${['tactical','emotional','balanced','witty'].map(p => `
            <label class="setup-radio ${this.data.personality===p?'active':''}">
              <input type="radio" name="personality" value="${p}" ${this.data.personality===p?'checked':''}>
              <span class="sr-icon">${{tactical:'⚡',emotional:'♡',balanced:'◈',witty:'◎'}[p]}</span>
              <span class="sr-label">${p.toUpperCase()}</span>
              <span class="sr-desc">${{tactical:'Mission-focused, precise',emotional:'Empathetic, expressive',balanced:'Adaptable, centred',witty:'Sharp, playful'}[p]}</span>
            </label>
          `).join('')}
        </div>
      </div>
    `;
    el.querySelector('#s-name').addEventListener('input', e => {
      this.data.name = e.target.value || 'ARIA';
      const n = document.getElementById('setup-preview-name');
      if (n) n.textContent = this.data.name;
    });
    el.querySelectorAll('input[name="personality"]').forEach(r => {
      r.addEventListener('change', e => {
        this.data.personality = e.target.value;
        el.querySelectorAll('.setup-radio').forEach(l => l.classList.remove('active'));
        r.closest('.setup-radio').classList.add('active');
      });
    });
  }

  _stepFace(el) {
    const skins = window.SKIN_TONES || {};
    const eyes  = window.EYE_COLORS  || {};
    el.innerHTML = `
      <div class="setup-step-title">FACE</div>
      <div class="setup-step-desc">Give her skin, give her eyes. She'll carry them always.</div>
      <div class="setup-field">
        <label class="setup-label">SKIN TONE</label>
        <div class="setup-swatch-row">
          ${Object.entries(skins).map(([k,v]) => `
            <button class="setup-swatch ${this.data.skinTone===k?'active':''}" data-key="skin-${k}"
              style="background:${v.hex}" title="${k}" data-val="${k}"></button>
          `).join('')}
        </div>
      </div>
      <div class="setup-field">
        <label class="setup-label">EYE COLOUR</label>
        <div class="setup-swatch-row">
          ${Object.entries(eyes).map(([k,v]) => `
            <button class="setup-swatch ${this.data.eyeColor===k?'active':''}" data-key="eye-${k}"
              style="background:${v.hex};width:28px;height:28px;border-radius:50%" title="${k}" data-val="${k}" data-type="eye"></button>
          `).join('')}
        </div>
      </div>
    `;
    el.querySelectorAll('.setup-swatch').forEach(btn => {
      btn.addEventListener('click', () => {
        const key  = btn.dataset.key;
        const type = btn.dataset.type;
        const val  = btn.dataset.val;
        if (type === 'eye') {
          this.data.eyeColor = val;
          el.querySelectorAll('[data-type="eye"]').forEach(b => b.classList.remove('active'));
        } else {
          this.data.skinTone = val;
          el.querySelectorAll(`.setup-swatch:not([data-type])`).forEach(b => b.classList.remove('active'));
        }
        btn.classList.add('active');
        this._refreshPreview();
      });
    });
  }

  _stepHair(el) {
    const hairs  = window.HAIR_COLORS || {};
    const styles = ['long','short','bun','pixie'];
    el.innerHTML = `
      <div class="setup-step-title">HAIR</div>
      <div class="setup-step-desc">How does she wear her hair? This can change later — but only by adding, not removing.</div>
      <div class="setup-field">
        <label class="setup-label">STYLE</label>
        <div class="setup-radio-grid two-col">
          ${styles.map(s => `
            <label class="setup-radio ${this.data.hairStyle===s?'active':''}">
              <input type="radio" name="hairstyle" value="${s}" ${this.data.hairStyle===s?'checked':''}>
              <span class="sr-icon">${{long:'💇',short:'✂',bun:'🔵',pixie:'⚡'}[s]}</span>
              <span class="sr-label">${s.toUpperCase()}</span>
            </label>
          `).join('')}
        </div>
      </div>
      <div class="setup-field">
        <label class="setup-label">HAIR COLOUR</label>
        <div class="setup-swatch-row">
          ${Object.entries(hairs).map(([k,v]) => `
            <button class="setup-swatch ${this.data.hairColor===k?'active':''}" data-val="${k}"
              style="background:${v.hex}" title="${k}"></button>
          `).join('')}
        </div>
      </div>
    `;
    el.querySelectorAll('input[name="hairstyle"]').forEach(r => {
      r.addEventListener('change', e => {
        this.data.hairStyle = e.target.value;
        el.querySelectorAll('[name="hairstyle"]').forEach(x => x.closest('.setup-radio').classList.remove('active'));
        r.closest('.setup-radio').classList.add('active');
        this._refreshPreview();
      });
    });
    el.querySelectorAll('.setup-swatch').forEach(btn => {
      btn.addEventListener('click', () => {
        this.data.hairColor = btn.dataset.val;
        el.querySelectorAll('.setup-swatch').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        this._refreshPreview();
      });
    });
  }

  _stepOutfit(el) {
    const outfits = ['tactical','armor','casual','robe'];
    const accents = ['#00FF41','#9D00FF','#00AAFF','#FF6600','#FFDD00','#FF0055','#FFFFFF','#AAAAAA'];
    el.innerHTML = `
      <div class="setup-step-title">OUTFIT</div>
      <div class="setup-step-desc">What does she wear into the field? Equipment can be upgraded — never replaced.</div>
      <div class="setup-field">
        <label class="setup-label">STYLE</label>
        <div class="setup-radio-grid two-col">
          ${outfits.map(o => `
            <label class="setup-radio ${this.data.outfit===o?'active':''}">
              <input type="radio" name="outfit" value="${o}" ${this.data.outfit===o?'checked':''}>
              <span class="sr-icon">${{tactical:'🎯',armor:'🛡',casual:'👤',robe:'🌙'}[o]}</span>
              <span class="sr-label">${o.toUpperCase()}</span>
            </label>
          `).join('')}
        </div>
      </div>
      <div class="setup-field">
        <label class="setup-label">ACCENT COLOUR</label>
        <div class="setup-swatch-row">
          ${accents.map(c => `
            <button class="setup-swatch ${this.data.outfitAccent===c?'active':''}" data-val="${c}"
              style="background:${c};width:26px;height:26px;border-radius:4px" title="${c}"></button>
          `).join('')}
        </div>
      </div>
    `;
    el.querySelectorAll('input[name="outfit"]').forEach(r => {
      r.addEventListener('change', e => {
        this.data.outfit = e.target.value;
        el.querySelectorAll('[name="outfit"]').forEach(x => x.closest('.setup-radio').classList.remove('active'));
        r.closest('.setup-radio').classList.add('active');
        this._refreshPreview();
      });
    });
    el.querySelectorAll('.setup-swatch').forEach(btn => {
      btn.addEventListener('click', () => {
        this.data.outfitAccent = btn.dataset.val;
        el.querySelectorAll('.setup-swatch').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        this._refreshPreview();
      });
    });
  }

  _stepMarkings(el) {
    const locs    = window.TATTOO_LOCATIONS || {};
    const designs = window.TATTOO_DESIGNS   || {};
    const colors  = ['#00FF41','#9D00FF','#00AAFF','#FF3333','#FFDD00','#FF69B4','#FFFFFF','#FF6600'];

    this.data._tattoo = this.data._tattoo || null;

    el.innerHTML = `
      <div class="setup-step-title">MARKINGS</div>
      <div class="setup-step-desc">
        Tattoos, scars, and markings are <strong>permanent</strong>. They become part of her.
        Removal requires running a specific removal module later — there are no quick undos.
      </div>
      <div class="setup-field">
        <label class="setup-label">ADD A MARKING?</label>
        <div style="display:flex;gap:10px;margin-bottom:12px">
          <button class="marking-toggle-btn ${!this.data._tattoo?'active':''}" data-val="no">SKIP — CLEAN SLATE</button>
          <button class="marking-toggle-btn ${this.data._tattoo?'active':''}" data-val="yes">YES — ADD MARKING</button>
        </div>
      </div>
      <div id="tattoo-fields" style="display:${this.data._tattoo?'block':'none'}">
        <div class="setup-field two-col-field">
          <div>
            <label class="setup-label">LOCATION</label>
            <select class="setup-select" id="t-loc">
              ${Object.entries(locs).map(([k,v]) => `<option value="${k}" ${this.data._tattoo?.details?.location===k?'selected':''}>${v}</option>`).join('')}
            </select>
          </div>
          <div>
            <label class="setup-label">DESIGN</label>
            <select class="setup-select" id="t-design">
              ${Object.entries(designs).map(([k,v]) => `<option value="${k}" ${this.data._tattoo?.details?.design===k?'selected':''}>${v}</option>`).join('')}
            </select>
          </div>
        </div>
        <div id="text-field" class="setup-field" style="display:none">
          <label class="setup-label">TATTOO TEXT</label>
          <input class="setup-input" id="t-text" type="text" value="${this.data._tattoo?.details?.text||''}" placeholder="e.g. JANUS" maxlength="12">
        </div>
        <div class="setup-field">
          <label class="setup-label">INK COLOUR</label>
          <div class="setup-swatch-row" id="tattoo-colors">
            ${colors.map(c => `
              <button class="setup-swatch ${(this.data._tattoo?.details?.color||'#00FF41')===c?'active':''}" data-val="${c}"
                style="background:${c};width:24px;height:24px;border-radius:50%" title="${c}"></button>
            `).join('')}
          </div>
        </div>
        <div class="setup-field">
          <label class="setup-label">SIZE</label>
          <input type="range" class="setup-range" id="t-size" min="3" max="10" value="${Math.round((this.data._tattoo?.details?.size||0.7)*10)}">
        </div>
      </div>
    `;

    // Toggle show/hide
    el.querySelectorAll('.marking-toggle-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const yes = btn.dataset.val === 'yes';
        el.querySelectorAll('.marking-toggle-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        document.getElementById('tattoo-fields').style.display = yes ? 'block' : 'none';
        if (!yes) { this.data._tattoo = null; this.data.initialMods = []; this._refreshPreview(); }
        else this._syncTattoo(el);
      });
    });

    const syncAndPreview = () => { this._syncTattoo(el); this._refreshPreview(); };
    ['t-loc','t-design','t-size'].forEach(id => {
      el.querySelector('#'+id)?.addEventListener('change', syncAndPreview);
      el.querySelector('#'+id)?.addEventListener('input', syncAndPreview);
    });
    el.querySelector('#t-design')?.addEventListener('change', e => {
      document.getElementById('text-field').style.display = e.target.value === 'text' ? 'block' : 'none';
      syncAndPreview();
    });
    el.querySelector('#t-text')?.addEventListener('input', syncAndPreview);
    el.querySelectorAll('#tattoo-colors .setup-swatch').forEach(btn => {
      btn.addEventListener('click', () => {
        el.querySelectorAll('#tattoo-colors .setup-swatch').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        syncAndPreview();
      });
    });
    if (document.getElementById('t-design')?.value === 'text') {
      document.getElementById('text-field').style.display = 'block';
    }
  }

  _syncTattoo(el) {
    const loc    = el.querySelector('#t-loc')?.value    || 'arm_left';
    const design = el.querySelector('#t-design')?.value || 'circuit';
    const color  = el.querySelector('#tattoo-colors .setup-swatch.active')?.dataset.val || '#00FF41';
    const size   = (el.querySelector('#t-size')?.value || 7) / 10;
    const text   = el.querySelector('#t-text')?.value || 'JANUS';
    this.data._tattoo = {
      id: 'init_tattoo', type: 'tattoo', added: new Date().toISOString(),
      removable: true, removalProcess: 'laser_removal',
      details: { location: loc, design, color, size, text, posX: 0.5, posY: 0.35 },
    };
    this.data.initialMods = [this.data._tattoo];
  }

  _stepConfirm(el) {
    const base = this.data;
    el.innerHTML = `
      <div class="setup-step-title">CONFIRMATION</div>
      <div class="setup-step-desc">
        She's ready. Once awakened, her identity locks in.<br>
        You can only <em>add</em> to her from this point forward.
      </div>
      <div class="confirm-summary">
        <div class="cs-row"><span class="cs-key">NAME</span><span class="cs-val">${this._esc(base.name)}</span></div>
        <div class="cs-row"><span class="cs-key">PERSONALITY</span><span class="cs-val">${base.personality.toUpperCase()}</span></div>
        <div class="cs-row"><span class="cs-key">SKIN</span><span class="cs-val">${base.skinTone.toUpperCase()}</span></div>
        <div class="cs-row"><span class="cs-key">EYES</span><span class="cs-val">${base.eyeColor.toUpperCase()}</span></div>
        <div class="cs-row"><span class="cs-key">HAIR</span><span class="cs-val">${base.hairColor.toUpperCase()} · ${base.hairStyle.toUpperCase()}</span></div>
        <div class="cs-row"><span class="cs-key">OUTFIT</span><span class="cs-val">${base.outfit.toUpperCase()}</span></div>
        <div class="cs-row"><span class="cs-key">MARKINGS</span><span class="cs-val">${base.initialMods.length ? base.initialMods[0].details.design.toUpperCase() + ' on ' + base.initialMods[0].details.location.replace('_',' ').toUpperCase() : 'NONE'}</span></div>
      </div>
      <div class="confirm-oath">
        "I understand that ${this._esc(base.name)}'s identity, once created, is permanent.<br>
        Modifications may be added. Nothing is truly erased."
      </div>
    `;
  }

  // ─── Navigation ────────────────────────────────────────────────────────────
  _next() {
    if (this.step < this.totalSteps - 1) {
      this.step++;
      this._renderStep();
    } else {
      this._awaken();
    }
  }

  _back() {
    if (this.step > 0) { this.step--; this._renderStep(); }
  }

  _awaken() {
    // Save profile
    this.pm.create(this.data);

    // Animate out
    this._overlay.style.animation = 'setup-exit 0.8s ease forwards';
    setTimeout(() => {
      if (this._previewAvatar) { this._previewAvatar.dispose(); this._previewAvatar = null; }
      this._overlay.remove();
      this.onComplete(this.pm.profile);
    }, 820);
  }

  _esc(str) {
    return String(str || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }
}

window.AriaSetupWizard = AriaSetupWizard;
