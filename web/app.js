/* ═══════════════════════════════════════════════════════════════
   JANUS-OS LAUNCHER — Frontend Logic
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
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(obj));
  }
}

function handleWsMessage(msg) {
  switch (msg.type) {
    case 'aria_thought':
      updateAriaThought(msg.text);
      break;
    case 'aria_response':
      appendAriaChat('ARIA', msg.text);
      break;
    case 'aria_status':
      if (msg.status) {
        opsCount = msg.status.ops_count || 0;
        updateOpsCount();
        updateAriaThought(msg.status.thought);
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

// ─── Boot Sequence ─────────────────────────────────────────────────────────────
const BOOT_STEPS = [
  { pct: 5,  label: 'Loading kernel modules...',           cls: '' },
  { pct: 12, label: 'Initialising udev device manager...',  cls: '' },
  { pct: 20, label: 'Starting ADB server...',               cls: 'ok' },
  { pct: 28, label: 'Mounting RAM filesystem...',           cls: 'ok' },
  { pct: 36, label: 'Loading Janus security layer...',      cls: 'ok' },
  { pct: 44, label: 'Initialising Lua runtime (54)...',     cls: 'ok' },
  { pct: 52, label: 'Loading core modules (22)...',         cls: 'ok' },
  { pct: 60, label: 'Loading plugin registry (10,626)...',  cls: 'ok' },
  { pct: 68, label: 'Starting Ghost-Net mesh...',           cls: 'ok' },
  { pct: 76, label: 'Initialising Blackbox recorder...',    cls: 'ok' },
  { pct: 84, label: 'Starting ARIA intelligence layer...',  cls: 'ok' },
  { pct: 92, label: 'ARIA — online. I\'m here.',            cls: 'ok' },
  { pct: 100, label: 'JanusOS ready.',                      cls: 'ok' },
];

function runBoot() {
  const progress   = document.getElementById('boot-progress');
  const label      = document.getElementById('boot-label');
  const log        = document.getElementById('boot-log');
  const ariaMsg    = document.getElementById('aria-boot-msg');

  let stepIdx = 0;

  function nextStep() {
    if (stepIdx >= BOOT_STEPS.length) {
      // Boot complete — transition to launcher
      setTimeout(showLauncher, 600);
      return;
    }
    const step = BOOT_STEPS[stepIdx++];
    progress.style.width = step.pct + '%';
    label.textContent = step.label;

    // Add to boot log
    const line = document.createElement('div');
    line.className = 'log-line' + (step.cls ? ' ' + step.cls : '');
    const ts = new Date().toISOString().substr(11, 8);
    line.textContent = `[${ts}] ${step.label}`;
    log.appendChild(line);
    log.scrollTop = log.scrollHeight;

    if (step.pct >= 84) {
      ariaMsg.textContent = 'ARIA — online and aware';
    }

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
}

// ─── Clock ─────────────────────────────────────────────────────────────────────
function startClock() {
  function tick() {
    const now  = new Date();
    const time = now.toTimeString().substr(0, 5);
    const date = now.toDateString().replace(/^\w+ /, '');
    document.getElementById('status-time').textContent = time;
    document.getElementById('status-date').textContent = date;
  }
  tick();
  setInterval(tick, 1000);
}

// ─── ARIA thought updates ──────────────────────────────────────────────────────
function updateAriaThought(text) {
  const el = document.getElementById('aria-bar-thought');
  if (!el) return;
  el.style.opacity = '0';
  setTimeout(() => {
    el.textContent = text;
    el.style.opacity = '1';
  }, 300);
}

function updateOpsCount() {
  const el = document.getElementById('ops-count');
  if (el) el.textContent = opsCount + ' ops';
}

// ─── App Tile / Dock handlers ──────────────────────────────────────────────────
function openApp(category, label) {
  if (category === 'aria_chat') {
    openAriaChat();
    return;
  }
  currentCategory = category;

  // Update app view header
  document.getElementById('app-title').textContent =
    (label || category).toUpperCase() + ' — MODULE RUNNER';
  document.getElementById('app-status').textContent = 'LOADING';
  document.getElementById('app-status').className = 'app-status-badge';

  // Clear module list and terminal
  document.getElementById('module-list').innerHTML =
    '<div style="padding:12px;font-size:0.6rem;color:var(--text3)">Loading modules...</div>';
  clearTerminal();
  appendTerminalLine('[JANUS] Loading module registry for: ' + (label || category).toUpperCase());
  appendTerminalLine('[ARIA]  Standing by. Select a module to run.');
  appendTerminalLine('');

  // Show app view
  document.getElementById('launcher').classList.add('hidden');
  const appView = document.getElementById('app-view');
  appView.classList.remove('hidden');

  // Rebuild layout
  appView.innerHTML = `
    <div id="app-header">
      <button id="app-back-btn" class="back-btn">◀ HOME</button>
      <div id="app-title">${(label || category).toUpperCase()} — MODULE RUNNER</div>
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
          <span id="terminal-title">// terminal output — ${(label||category).toUpperCase()}</span>
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

  // Re-attach handlers
  document.getElementById('app-back-btn').addEventListener('click', goHome);
  document.getElementById('clear-btn').addEventListener('click', clearTerminal);
  document.getElementById('terminal-input').addEventListener('keydown', onTerminalInput);

  appendTerminalLine('[JANUS] Loading module registry for: ' + (label || category).toUpperCase());
  appendTerminalLine('[ARIA]  Standing by. Select a module to run.');
  appendTerminalLine('');

  // Request module list from backend
  wsSend({ type: 'get_modules', category: category });

  document.getElementById('app-status').textContent = 'READY';
}

function goHome() {
  document.getElementById('app-view').classList.add('hidden');
  document.getElementById('launcher').classList.remove('hidden');
  currentCategory = null;
}

// ─── Module list rendering ─────────────────────────────────────────────────────
function renderModuleList(modules, category) {
  const container = document.getElementById('module-list');
  if (!container) return;

  if (!modules || modules.length === 0) {
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

  // Update status
  const statusEl = document.getElementById('app-status');
  if (statusEl) {
    statusEl.textContent = modules.length + ' MODULES';
    statusEl.className = 'app-status-badge';
  }
  appendTerminalLine(`[REGISTRY] ${modules.length} modules loaded for ${(category||'').toUpperCase()}`);
}

// ─── Module execution ──────────────────────────────────────────────────────────
function runModule(mod, category) {
  const statusEl = document.getElementById('app-status');
  if (statusEl) {
    statusEl.textContent = 'RUNNING';
    statusEl.className = 'app-status-badge running';
  }

  appendTerminalLine('');
  appendTerminalLine(`[EXEC]  Launching: ${mod.display || mod.name}`);

  wsSend({
    type: 'run_module',
    category: category || currentCategory || '',
    module: mod.file || mod.name,
  });

  // Re-enable status after a moment
  setTimeout(() => {
    if (statusEl) {
      statusEl.textContent = 'READY';
      statusEl.className = 'app-status-badge';
    }
    opsCount++;
    updateOpsCount();
  }, 4000);
}

// ─── Terminal helpers ──────────────────────────────────────────────────────────
function appendTerminalLine(text) {
  const out = document.getElementById('terminal-output');
  if (!out) return;

  const div = document.createElement('div');
  if (!text || text.trim() === '') {
    div.className = 'term-line term-blank';
    div.innerHTML = '&nbsp;';
  } else {
    div.className = 'term-line' + getLineClass(text);
    div.textContent = text;
  }
  out.appendChild(div);
  out.scrollTop = out.scrollHeight;
}

function getLineClass(text) {
  if (text.includes('[ARIA]') || text.includes('ARIA:')) return ' aria-line';
  if (text.includes('✓') || text.includes('[DONE]') || text.includes('[OK]')) return ' ok-line';
  if (text.includes('WARN') || text.includes('PARTIAL')) return ' warn-line';
  if (text.startsWith('═') || text.startsWith('─') || text.startsWith('╔') ||
      text.startsWith('╚') || text.startsWith('━')) return ' sep-line';
  return '';
}

function clearTerminal() {
  const out = document.getElementById('terminal-output');
  if (out) out.innerHTML = '';
}

function onTerminalInput(e) {
  if (e.key !== 'Enter') return;
  const input = document.getElementById('terminal-input');
  const val = input.value.trim();
  if (!val) return;
  input.value = '';
  appendTerminalLine('JANUS ❯ ' + val);

  // Route commands
  if (val === 'help') {
    appendTerminalLine('[HELP] Commands: clear, status, aria <message>, modules, back');
  } else if (val === 'clear') {
    clearTerminal();
  } else if (val === 'status') {
    appendTerminalLine('[STATUS] JanusOS operational. ARIA online. ' + opsCount + ' ops executed.');
  } else if (val === 'back') {
    goHome();
  } else if (val === 'modules') {
    if (currentCategory) wsSend({ type: 'get_modules', category: currentCategory });
  } else if (val.startsWith('aria ')) {
    const msg = val.slice(5);
    wsSend({ type: 'aria_chat', message: msg });
    appendTerminalLine('[USER → ARIA] ' + msg);
  } else {
    appendTerminalLine('[JANUS] Unknown command: ' + val + '. Type "help" for options.');
  }
}

// ─── ARIA Chat ─────────────────────────────────────────────────────────────────
function openAriaChat() {
  document.getElementById('aria-chat-overlay').classList.remove('hidden');
  setTimeout(() => {
    const input = document.getElementById('aria-input');
    if (input) input.focus();
  }, 300);
}

function closeAriaChat() {
  document.getElementById('aria-chat-overlay').classList.add('hidden');
}

function sendAriaMessage() {
  const input = document.getElementById('aria-input');
  const text = input.value.trim();
  if (!text) return;
  input.value = '';

  appendAriaChat('YOU', text);
  wsSend({ type: 'aria_chat', message: text });

  // Typing indicator
  const typing = document.createElement('div');
  typing.className = 'chat-msg aria-msg';
  typing.id = 'aria-typing';
  typing.innerHTML = `<span class="chat-from">ARIA</span><span class="chat-text" style="color:var(--text3);font-style:italic">thinking...</span>`;
  document.getElementById('aria-chat-messages').appendChild(typing);
  scrollChatToBottom();
}

function appendAriaChat(from, text) {
  // Remove typing indicator
  const typing = document.getElementById('aria-typing');
  if (typing) typing.remove();

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

// ─── Utility ───────────────────────────────────────────────────────────────────
function escHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// ─── Event Listeners ───────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {

  // App tile clicks
  document.querySelectorAll('.app-tile').forEach(tile => {
    tile.addEventListener('click', () => {
      openApp(tile.dataset.category, tile.dataset.label);
    });
  });

  // Dock clicks
  document.querySelectorAll('.dock-item').forEach(item => {
    item.addEventListener('click', () => {
      const cat = item.dataset.category;
      const label = item.querySelector('span')?.textContent || cat;
      openApp(cat, label);
    });
  });

  // ARIA bar chat button
  document.getElementById('aria-chat-btn')?.addEventListener('click', openAriaChat);

  // ARIA chat close
  document.getElementById('aria-chat-close')?.addEventListener('click', closeAriaChat);

  // ARIA send
  document.getElementById('aria-send-btn')?.addEventListener('click', sendAriaMessage);
  document.getElementById('aria-input')?.addEventListener('keydown', e => {
    if (e.key === 'Enter') sendAriaMessage();
  });

  // Close chat on overlay background click
  document.getElementById('aria-chat-overlay')?.addEventListener('click', e => {
    if (e.target === document.getElementById('aria-chat-overlay')) closeAriaChat();
  });

  // App view back button (initial, before it gets rebuilt)
  document.getElementById('app-back-btn')?.addEventListener('click', goHome);
  document.getElementById('clear-btn')?.addEventListener('click', clearTerminal);
  document.getElementById('terminal-input')?.addEventListener('keydown', onTerminalInput);

  // Start boot
  runBoot();
});
