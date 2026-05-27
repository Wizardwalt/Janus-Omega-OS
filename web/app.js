/* ═══════════════════════════════════════════════════════════════
   JANUS-OS LAUNCHER — Frontend Logic + ARIA 3D Avatar System
   ═══════════════════════════════════════════════════════════════ */

'use strict';

// ─── WebSocket ────────────────────────────────────────────────────────────────
let ws = null;
let wsReady = false;
let currentCategory = null;
let opsCount = 0;

const WS_URL = `ws://${location.host}/ws`;

function connectWS() {
  ws = new WebSocket(WS_URL);
  ws.onopen = () => {
    wsReady = true;
    console.log('[WS] Connected to JanusOS backend');
  };
  ws.onmessage = (evt) => {
    try { handleWsMessage(JSON.parse(evt.data)); }
    catch(e) { console.warn('[WS] parse error', e); }
  };
  ws.onclose = () => {
    wsReady = false;
    setTimeout(connectWS, 2000);
  };
  ws.onerror = () => ws.close();
}

function wsSend(obj) {
  if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(obj));
}

function handleWsMessage(msg) {
  switch (msg.type) {
    case 'aria_thought':
      updateAriaThought(msg.text);
      setAriaMood(pickMoodFromText(msg.text));
      break;
    case 'aria_response':
      appendAriaChat('ARIA', msg.text);
      appendAriaViewChat('ARIA', msg.text);
      if (avatarMain) { avatarMain.speak(true); setTimeout(() => avatarMain.speak(false), 3500); }
      if (avatarChat) { avatarChat.speak(true); setTimeout(() => avatarChat.speak(false), 3500); }
      if (avatarMini) { avatarMini.speak(true); setTimeout(() => avatarMini.speak(false), 3500); }
      setAriaMood(pickMoodFromText(msg.text));
      break;
    case 'aria_status':
      if (msg.status) {
        opsCount = msg.status.ops_count || 0;
        updateOpsCount();
        updateAriaThought(msg.status.thought);
        setAriaMood(pickMoodFromText(msg.status.thought));
      }
      break;
    case 'module_list':
      renderModuleList(msg.modules || [], msg.category);
      break;
    case 'output':
      appendTerminalLine(msg.line || '');
      break;
    case 'pong':
      break;
  }
}

// ─── Mood inference from text ─────────────────────────────────────────────────
function pickMoodFromText(text) {
  if (!text) return 'neutral';
  const t = text.toLowerCase();
  if (t.includes('process') || t.includes('analys') || t.includes('calculat') || t.includes('scan')) return 'processing';
  if (t.includes('alert') || t.includes('danger') || t.includes('threat') || t.includes('critical')) return 'excited';
  if (t.includes('curios') || t.includes('interest') || t.includes('wonder') || t.includes('hmm')) return 'curious';
  if (t.includes('success') || t.includes('complete') || t.includes('done') || t.includes('ready')) return 'happy';
  if (t.includes('fail') || t.includes('error') || t.includes('lost') || t.includes('disconnect')) return 'sad';
  return 'neutral';
}

// ─── ARIA 3D Avatar instances ─────────────────────────────────────────────────
let avatarMain    = null;   // Full view (aria-view)
let avatarChat    = null;   // Chat overlay header mini
let avatarMini    = null;   // ARIA bar mini (48×48)
let avatarProject = null;   // Life-size projection

const AVATAR_DEFAULT_OPTS = {
  primaryColor:   0x9D00FF,
  secondaryColor: 0x00FF41,
  glowIntensity:  1.0,
  style:          'holographic',
  hairStyle:      'long',
  outfit:         'tactical',
  height:         1.0,
  mood:           'curious',
};

// Current customisation state (shared)
let avatarOpts = { ...AVATAR_DEFAULT_OPTS };

function initMiniAvatar() {
  const canvas = document.getElementById('aria-mini-canvas');
  if (!canvas || !window.AriaAvatar3D) return;
  avatarMini = new AriaAvatar3D(canvas, {
    ...avatarOpts,
    glowIntensity: 1.2,
  });
}

function initChatAvatar() {
  const canvas = document.getElementById('aria-chat-canvas');
  if (!canvas || !window.AriaAvatar3D) return;
  avatarChat = new AriaAvatar3D(canvas, {
    ...avatarOpts,
    glowIntensity: 1.4,
  });
}

function initMainAvatar() {
  const canvas = document.getElementById('aria-main-canvas');
  if (!canvas || !window.AriaAvatar3D || avatarMain) return;
  // Size canvas to parent
  const parent = document.getElementById('aria-3d-panel');
  if (parent) {
    canvas.width  = parent.clientWidth;
    canvas.height = parent.clientHeight;
  }
  avatarMain = new AriaAvatar3D(canvas, { ...avatarOpts });
}

function initProjectionAvatar() {
  const canvas = document.getElementById('aria-project-canvas');
  if (!canvas || !window.AriaAvatar3D || avatarProject) return;
  canvas.width  = window.innerWidth;
  canvas.height = window.innerHeight;
  avatarProject = new AriaAvatar3D(canvas, {
    ...avatarOpts,
    glowIntensity: 1.8,
    height: 1.0,
  });
  avatarProject.projectLifeSize(true);
  if (avatarProject) avatarProject.setMood(avatarOpts.mood || 'curious');
}

function setAriaMood(mood) {
  avatarOpts.mood = mood;
  if (avatarMain)    avatarMain.setMood(mood);
  if (avatarChat)    avatarChat.setMood(mood);
  if (avatarMini)    avatarMini.setMood(mood);
  if (avatarProject) avatarProject.setMood(mood);

  const moodNames = {
    neutral:    '◉ NEUTRAL',
    curious:    '◉ CURIOUS',
    happy:      '◉ HAPPY',
    excited:    '⚡ EXCITED',
    processing: '⟳ PROCESSING',
    sad:        '◎ REFLECTIVE',
  };
  const badge = document.getElementById('aria-mood-badge');
  if (badge) badge.textContent = moodNames[mood] || '◉ NEUTRAL';
  const moodEl = document.getElementById('aria-mood-name');
  if (moodEl) moodEl.textContent = moodNames[mood] || '◉ NEUTRAL';

  // Update active mood button
  document.querySelectorAll('.mood-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.mood === mood);
  });
}

function applyAvatarCustomisation(opts) {
  avatarOpts = { ...avatarOpts, ...opts };
  if (avatarMain)    avatarMain.customize(opts);
  if (avatarChat)    avatarChat.customize(opts);
  if (avatarMini)    avatarMini.customize(opts);
  if (avatarProject) avatarProject.customize(opts);
}

// ─── Boot Sequence ─────────────────────────────────────────────────────────────
const BOOT_STEPS = [
  { pct: 5,  label: 'Loading kernel modules...',              cls: '' },
  { pct: 12, label: 'Initialising udev device manager...',    cls: '' },
  { pct: 20, label: 'Starting ADB server...',                 cls: 'ok' },
  { pct: 28, label: 'Mounting RAM filesystem...',             cls: 'ok' },
  { pct: 36, label: 'Loading Janus security layer...',        cls: 'ok' },
  { pct: 44, label: 'Initialising Lua runtime (54)...',       cls: 'ok' },
  { pct: 52, label: 'Loading core modules (22)...',           cls: 'ok' },
  { pct: 60, label: 'Loading plugin registry (10,626)...',    cls: 'ok' },
  { pct: 68, label: 'Starting Ghost-Net mesh...',             cls: 'ok' },
  { pct: 76, label: 'Initialising Blackbox recorder...',      cls: 'ok' },
  { pct: 84, label: 'Materialising ARIA holographic form...', cls: 'ok' },
  { pct: 92, label: 'ARIA — online. I\'m here.',              cls: 'ok' },
  { pct: 100, label: 'JanusOS ready.',                        cls: 'ok' },
];

function runBoot() {
  const progress = document.getElementById('boot-progress');
  const label    = document.getElementById('boot-label');
  const log      = document.getElementById('boot-log');
  const ariaMsg  = document.getElementById('aria-boot-msg');
  let stepIdx = 0;

  function nextStep() {
    if (stepIdx >= BOOT_STEPS.length) { setTimeout(showLauncher, 600); return; }
    const step = BOOT_STEPS[stepIdx++];
    progress.style.width = step.pct + '%';
    label.textContent = step.label;
    const line = document.createElement('div');
    line.className = 'log-line' + (step.cls ? ' ' + step.cls : '');
    const ts = new Date().toISOString().substr(11, 8);
    line.textContent = `[${ts}] ${step.label}`;
    log.appendChild(line);
    log.scrollTop = log.scrollHeight;
    if (step.pct >= 84) ariaMsg.textContent = 'ARIA — holographic form materialising';
    if (step.pct >= 92) ariaMsg.textContent = 'ARIA — online and present';
    const delay = stepIdx === 1 ? 400 : (step.cls === 'ok' ? 220 : 380);
    setTimeout(nextStep, delay);
  }
  nextStep();
}

function showLauncher() {
  document.getElementById('boot-screen').classList.add('hidden');
  document.getElementById('launcher').classList.remove('hidden');
  connectWS();
  startClock();
  // Init mini avatar after launcher shows (Three.js needs visible canvas)
  requestAnimationFrame(() => {
    initMiniAvatar();
    setAriaMood('curious');
  });
}

// ─── Clock ─────────────────────────────────────────────────────────────────────
function startClock() {
  function tick() {
    const now  = new Date();
    document.getElementById('status-time').textContent = now.toTimeString().substr(0, 5);
    document.getElementById('status-date').textContent = now.toDateString().replace(/^\w+ /, '');
  }
  tick();
  setInterval(tick, 1000);
}

// ─── ARIA thought bar ──────────────────────────────────────────────────────────
function updateAriaThought(text) {
  const el = document.getElementById('aria-bar-thought');
  if (!el) return;
  el.style.opacity = '0';
  setTimeout(() => { el.textContent = text; el.style.opacity = '1'; }, 300);
  // Update projection overlay thought
  const pt = document.getElementById('projection-thought');
  if (pt) { pt.style.opacity = '0'; setTimeout(() => { pt.textContent = `"${text}"`; pt.style.opacity = '1'; }, 300); }
  // Update view status
  const sl = document.getElementById('aria-status-label');
  if (sl) sl.textContent = 'ACTIVE';
}

function updateOpsCount() {
  const el = document.getElementById('ops-count');
  if (el) el.textContent = opsCount + ' ops';
}

// ─── App Tile / Dock handlers ──────────────────────────────────────────────────
function openApp(category, label) {
  if (category === 'aria_avatar' || category === 'aria_chat') {
    openAriaView();
    return;
  }
  currentCategory = category;

  document.getElementById('launcher').classList.add('hidden');
  const appView = document.getElementById('app-view');
  appView.classList.remove('hidden');

  appView.innerHTML = `
    <div id="app-header">
      <button id="app-back-btn" class="back-btn">◀ HOME</button>
      <div id="app-title">${escHtml((label || category).toUpperCase())} — MODULE RUNNER</div>
      <div id="app-status" class="app-status-badge">LOADING</div>
    </div>
    <div class="app-body">
      <div id="module-list-panel">
        <div id="module-list-header">SELECT MODULE</div>
        <div id="module-list" class="module-list">
          <div style="padding:12px;font-size:0.6rem;color:var(--text3)">Loading modules...</div>
        </div>
      </div>
      <div id="terminal-panel">
        <div id="terminal-header">
          <span id="terminal-title">// terminal — ${escHtml((label||category).toUpperCase())}</span>
          <button id="clear-btn" class="clear-btn">CLEAR</button>
        </div>
        <div id="terminal-output" class="terminal-output"></div>
        <div id="terminal-input-row">
          <span class="term-prompt">JANUS ❯</span>
          <input id="terminal-input" type="text" placeholder="Select a module above to execute..." autocomplete="off" spellcheck="false">
        </div>
      </div>
    </div>
  `;

  document.getElementById('app-back-btn').addEventListener('click', goHome);
  document.getElementById('clear-btn').addEventListener('click', clearTerminal);
  document.getElementById('terminal-input').addEventListener('keydown', onTerminalInput);

  appendTerminalLine('[JANUS] Loading module registry for: ' + (label || category).toUpperCase());
  appendTerminalLine('[ARIA]  Standing by. Select a module to run.');
  appendTerminalLine('');

  wsSend({ type: 'get_modules', category });
  document.getElementById('app-status').textContent = 'READY';
}

function goHome() {
  document.getElementById('app-view').classList.add('hidden');
  document.getElementById('aria-view').classList.add('hidden');
  document.getElementById('launcher').classList.remove('hidden');
  currentCategory = null;
}

// ─── Module list rendering ─────────────────────────────────────────────────────
function renderModuleList(modules, category) {
  const container = document.getElementById('module-list');
  if (!container) return;
  if (!modules || !modules.length) {
    container.innerHTML = '<div style="padding:12px;font-size:0.6rem;color:var(--text3)">No modules found.</div>';
    return;
  }
  container.innerHTML = '';
  modules.forEach(mod => {
    const item = document.createElement('div');
    item.className = 'module-item';
    item.innerHTML = `
      <div class="m-name">${escHtml(mod.display || mod.name)}</div>
      <div class="m-desc">${escHtml(mod.description || 'Operational module')}</div>
    `;
    item.addEventListener('click', () => runModule(mod, category));
    container.appendChild(item);
  });
  const statusEl = document.getElementById('app-status');
  if (statusEl) { statusEl.textContent = modules.length + ' MODULES'; statusEl.className = 'app-status-badge'; }
  appendTerminalLine(`[REGISTRY] ${modules.length} modules loaded for ${(category||'').toUpperCase()}`);
}

// ─── Module execution ──────────────────────────────────────────────────────────
function runModule(mod, category) {
  const statusEl = document.getElementById('app-status');
  if (statusEl) { statusEl.textContent = 'RUNNING'; statusEl.className = 'app-status-badge running'; }
  appendTerminalLine('');
  appendTerminalLine(`[EXEC]  Launching: ${mod.display || mod.name}`);
  wsSend({ type: 'run_module', category: category || currentCategory || '', module: mod.file || mod.name });
  setAriaMood('processing');
  setTimeout(() => {
    if (statusEl) { statusEl.textContent = 'READY'; statusEl.className = 'app-status-badge'; }
    opsCount++;
    updateOpsCount();
    setAriaMood('happy');
    setTimeout(() => setAriaMood('curious'), 4000);
  }, 4000);
}

// ─── Terminal helpers ──────────────────────────────────────────────────────────
function appendTerminalLine(text) {
  const out = document.getElementById('terminal-output');
  if (!out) return;
  const div = document.createElement('div');
  if (!text || text.trim() === '') {
    div.className = 'term-line term-blank'; div.innerHTML = '&nbsp;';
  } else {
    div.className = 'term-line' + getLineClass(text);
    div.textContent = text;
  }
  out.appendChild(div);
  out.scrollTop = out.scrollHeight;
}

function getLineClass(text) {
  if (text.includes('[ARIA]') || text.includes('ARIA:'))    return ' aria-line';
  if (text.includes('✓') || text.includes('[DONE]') || text.includes('[OK]')) return ' ok-line';
  if (text.includes('WARN') || text.includes('PARTIAL'))    return ' warn-line';
  if (text.startsWith('═') || text.startsWith('─') || text.startsWith('╔') ||
      text.startsWith('╚') || text.startsWith('━'))         return ' sep-line';
  return '';
}

function clearTerminal() {
  const out = document.getElementById('terminal-output');
  if (out) out.innerHTML = '';
}

function onTerminalInput(e) {
  if (e.key !== 'Enter') return;
  const input = document.getElementById('terminal-input');
  const val = input.value.trim(); if (!val) return;
  input.value = '';
  appendTerminalLine('JANUS ❯ ' + val);
  if (val === 'help')    { appendTerminalLine('[HELP] Commands: clear, status, aria <message>, modules, back'); }
  else if (val === 'clear')   { clearTerminal(); }
  else if (val === 'status')  { appendTerminalLine('[STATUS] JanusOS operational. ARIA online. ' + opsCount + ' ops.'); }
  else if (val === 'back')    { goHome(); }
  else if (val === 'modules') { if (currentCategory) wsSend({ type: 'get_modules', category: currentCategory }); }
  else if (val.startsWith('aria ')) {
    const msg = val.slice(5);
    wsSend({ type: 'aria_chat', message: msg });
    appendTerminalLine('[YOU → ARIA] ' + msg);
    setAriaMood('processing');
  } else {
    appendTerminalLine('[JANUS] Unknown command: ' + val + '. Type "help".');
  }
}

// ─── ARIA Full View ────────────────────────────────────────────────────────────
function openAriaView() {
  document.getElementById('launcher').classList.add('hidden');
  const view = document.getElementById('aria-view');
  view.classList.remove('hidden');

  // Init main avatar on first open
  requestAnimationFrame(() => {
    if (!avatarMain) initMainAvatar();
    setAriaMood(avatarOpts.mood || 'curious');
  });
}

function closeAriaView() {
  document.getElementById('aria-view').classList.add('hidden');
  document.getElementById('launcher').classList.remove('hidden');
}

function appendAriaViewChat(from, text) {
  const msgs = document.getElementById('aria-view-messages');
  if (!msgs) return;
  const isAria = from === 'ARIA';
  const msg = document.createElement('div');
  msg.className = 'chat-msg ' + (isAria ? 'aria-msg' : 'user-msg');
  msg.innerHTML = `<span class="chat-from">${escHtml(from)}</span><span class="chat-text">${escHtml(text)}</span>`;
  msgs.appendChild(msg);
  msgs.scrollTop = msgs.scrollHeight;
}

function sendAriaViewMessage() {
  const input = document.getElementById('aria-view-input');
  if (!input) return;
  const text = input.value.trim(); if (!text) return;
  input.value = '';
  appendAriaViewChat('YOU', text);
  wsSend({ type: 'aria_chat', message: text });
  setAriaMood('processing');

  // Show typing indicator
  const typing = document.createElement('div');
  typing.className = 'chat-msg aria-msg'; typing.id = 'aria-view-typing';
  typing.innerHTML = `<span class="chat-from">ARIA</span><span class="chat-text" style="color:var(--text3);font-style:italic">thinking...</span>`;
  const msgs = document.getElementById('aria-view-messages');
  if (msgs) { msgs.appendChild(typing); msgs.scrollTop = msgs.scrollHeight; }
}

// ─── ARIA Quick Chat Overlay ───────────────────────────────────────────────────
function openAriaChat() {
  document.getElementById('aria-chat-overlay').classList.remove('hidden');
  // Init chat overlay avatar
  requestAnimationFrame(() => {
    if (!avatarChat) initChatAvatar();
    setAriaMood(avatarOpts.mood || 'curious');
  });
  setTimeout(() => { document.getElementById('aria-input')?.focus(); }, 300);
}

function closeAriaChat() {
  document.getElementById('aria-chat-overlay').classList.add('hidden');
}

function sendAriaMessage() {
  const input = document.getElementById('aria-input');
  const text = input.value.trim(); if (!text) return;
  input.value = '';
  appendAriaChat('YOU', text);
  wsSend({ type: 'aria_chat', message: text });
  setAriaMood('processing');
  // Typing indicator
  const typing = document.createElement('div');
  typing.className = 'chat-msg aria-msg'; typing.id = 'aria-typing';
  typing.innerHTML = `<span class="chat-from">ARIA</span><span class="chat-text" style="color:var(--text3);font-style:italic">thinking...</span>`;
  document.getElementById('aria-chat-messages').appendChild(typing);
  scrollChatToBottom();
}

function appendAriaChat(from, text) {
  document.getElementById('aria-typing')?.remove();
  document.getElementById('aria-view-typing')?.remove();
  const msgs = document.getElementById('aria-chat-messages');
  if (!msgs) return;
  const isAria = from === 'ARIA';
  const msg = document.createElement('div');
  msg.className = 'chat-msg ' + (isAria ? 'aria-msg' : 'user-msg');
  msg.innerHTML = `<span class="chat-from">${escHtml(from)}</span><span class="chat-text">${escHtml(text)}</span>`;
  msgs.appendChild(msg);
  scrollChatToBottom();
}

function scrollChatToBottom() {
  const msgs = document.getElementById('aria-chat-messages');
  if (msgs) msgs.scrollTop = msgs.scrollHeight;
}

// ─── Projection Mode (life-size) ──────────────────────────────────────────────
function openProjection() {
  const overlay = document.getElementById('projection-overlay');
  overlay.classList.remove('hidden');
  requestAnimationFrame(() => {
    initProjectionAvatar();
    setAriaMood(avatarOpts.mood || 'curious');
    // Show current thought
    const thought = document.getElementById('aria-bar-thought')?.textContent || '';
    const pt = document.getElementById('projection-thought');
    if (pt && thought) pt.textContent = `"${thought}"`;
  });
}

function closeProjection() {
  document.getElementById('projection-overlay').classList.add('hidden');
  if (avatarProject) {
    avatarProject.dispose();
    avatarProject = null;
  }
}

// ─── Customisation panel handlers ────────────────────────────────────────────
function initCustomisationHandlers() {

  // Primary colour swatches (first .color-row not in accent row)
  const colorRows = document.querySelectorAll('.color-row');
  if (colorRows[0]) {
    colorRows[0].querySelectorAll('.color-swatch').forEach(btn => {
      btn.addEventListener('click', () => {
        colorRows[0].querySelectorAll('.color-swatch').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        applyAvatarCustomisation({ primaryColor: parseInt(btn.dataset.color, 16) });
      });
    });
  }

  // Accent colour swatches
  const accentRow = document.getElementById('accent-color-row');
  if (accentRow) {
    accentRow.querySelectorAll('.color-swatch').forEach(btn => {
      btn.addEventListener('click', () => {
        accentRow.querySelectorAll('.color-swatch').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        applyAvatarCustomisation({ secondaryColor: parseInt(btn.dataset.color, 16) });
      });
    });
  }

  // Hair
  document.getElementById('hair-select')?.addEventListener('change', e => {
    applyAvatarCustomisation({ hairStyle: e.target.value });
  });

  // Outfit
  document.getElementById('outfit-select')?.addEventListener('change', e => {
    applyAvatarCustomisation({ outfit: e.target.value });
  });

  // Style
  document.getElementById('style-select')?.addEventListener('change', e => {
    applyAvatarCustomisation({ style: e.target.value });
  });

  // Glow
  const glowRange = document.getElementById('glow-range');
  const glowVal   = document.getElementById('glow-val');
  if (glowRange) {
    glowRange.addEventListener('input', () => {
      const v = glowRange.value / 10;
      if (glowVal) glowVal.textContent = v.toFixed(1) + '×';
      applyAvatarCustomisation({ glowIntensity: v });
    });
  }

  // Height
  const heightRange = document.getElementById('height-range');
  const heightVal   = document.getElementById('height-val');
  if (heightRange) {
    heightRange.addEventListener('input', () => {
      const v = heightRange.value / 10;
      if (heightVal) heightVal.textContent = v.toFixed(1) + '×';
      applyAvatarCustomisation({ height: v });
    });
  }

  // Mood buttons
  document.querySelectorAll('.mood-btn').forEach(btn => {
    btn.addEventListener('click', () => setAriaMood(btn.dataset.mood));
  });

  // Customise toggle
  document.getElementById('customize-toggle-btn')?.addEventListener('click', () => {
    const panel = document.getElementById('aria-customize-panel');
    if (panel) panel.classList.toggle('hidden');
  });
}

// ─── Utility ───────────────────────────────────────────────────────────────────
function escHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// ─── Event Listeners ───────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {

  // App tile clicks
  document.querySelectorAll('.app-tile').forEach(tile => {
    tile.addEventListener('click', () => openApp(tile.dataset.category, tile.dataset.label));
  });

  // Dock clicks
  document.querySelectorAll('.dock-item').forEach(item => {
    item.addEventListener('click', () => {
      const cat   = item.dataset.category;
      const label = item.querySelector('span')?.textContent || cat;
      openApp(cat, label);
    });
  });

  // ARIA bar chat button → quick chat overlay
  document.getElementById('aria-chat-btn')?.addEventListener('click', openAriaChat);

  // ARIA bar avatar click → full view
  document.getElementById('aria-bar-avatar-wrap')?.addEventListener('click', openAriaView);

  // ARIA chat close
  document.getElementById('aria-chat-close')?.addEventListener('click', closeAriaChat);
  document.getElementById('aria-send-btn')?.addEventListener('click', sendAriaMessage);
  document.getElementById('aria-input')?.addEventListener('keydown', e => { if (e.key === 'Enter') sendAriaMessage(); });
  document.getElementById('aria-chat-overlay')?.addEventListener('click', e => {
    if (e.target === document.getElementById('aria-chat-overlay')) closeAriaChat();
  });

  // ARIA full view
  document.getElementById('aria-view-back')?.addEventListener('click', closeAriaView);
  document.getElementById('aria-view-send-btn')?.addEventListener('click', sendAriaViewMessage);
  document.getElementById('aria-view-input')?.addEventListener('keydown', e => { if (e.key === 'Enter') sendAriaViewMessage(); });

  // Projection
  document.getElementById('project-btn')?.addEventListener('click', openProjection);
  document.getElementById('projection-exit-btn')?.addEventListener('click', closeProjection);
  // Tap anywhere on projection to exit
  document.getElementById('projection-overlay')?.addEventListener('click', e => {
    if (e.target === document.getElementById('projection-overlay') ||
        e.target === document.getElementById('aria-project-canvas')) closeProjection();
  });

  // Customisation
  initCustomisationHandlers();

  // Start boot sequence
  runBoot();
});
