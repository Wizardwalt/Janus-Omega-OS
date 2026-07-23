/* Authenticated hardware readiness panel: reports actual adapter state only. */
'use strict';

function createHardwarePanel() {
  const panel = document.createElement('section');
  panel.id = 'runtime-hardware-panel';
  panel.style.cssText = 'position:fixed;left:16px;top:16px;z-index:9997;width:min(360px,calc(100vw - 32px));padding:12px;border:1px solid #ff7b2b;background:#1c0d06;color:#ffe1cc;font:11px monospace;display:none;';
  panel.innerHTML = '<strong>HARDWARE READINESS</strong><div data-content style="margin-top:8px">Waiting for authenticated session.</div>';
  document.body.appendChild(panel);
}

async function refreshHardwarePanel() {
  const panel = document.getElementById('runtime-hardware-panel');
  const content = panel?.querySelector('[data-content]');
  if (!panel || !content || !window.janusRuntime.hasSession()) return;
  panel.style.display = 'block'; content.textContent = 'Checking real hardware adapter status...';
  try {
    const adapters = await window.janusRuntime.hardwareStatus();
    content.replaceChildren();
    adapters.forEach(adapter => {
      const row = document.createElement('div');
      row.style.margin = '5px 0';
      row.textContent = `${adapter.adapter.toUpperCase()}: ${adapter.state.toUpperCase()} — ${adapter.detail}`;
      row.style.color = adapter.state === 'available' ? '#9affaa' : adapter.state === 'unavailable' ? '#ffd166' : '#ff9e7a';
      content.appendChild(row);
    });
    const refresh = document.createElement('button'); refresh.type = 'button'; refresh.textContent = 'REFRESH HARDWARE'; refresh.style.marginTop = '8px'; refresh.addEventListener('click', refreshHardwarePanel); content.appendChild(refresh);
  } catch (error) { content.textContent = `Hardware status unavailable: ${error.message}`; }
}
document.addEventListener('DOMContentLoaded', createHardwarePanel);
window.addEventListener('janus:session', refreshHardwarePanel);
window.addEventListener('janus:logout', () => { const panel = document.getElementById('runtime-hardware-panel'); if (panel) panel.style.display = 'none'; });
