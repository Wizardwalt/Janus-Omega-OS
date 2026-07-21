/* Read-only production status view backed by authenticated Janus runtime APIs. */
'use strict';

function createRuntimeStatusPanel() {
  const panel = document.createElement('section');
  panel.id = 'runtime-status-panel';
  panel.style.cssText = 'position:fixed;left:16px;bottom:16px;z-index:9999;width:min(360px,calc(100vw - 32px));padding:12px;border:1px solid #138cff;background:#06101a;color:#d5ecff;font:11px monospace;box-shadow:0 0 20px #138cff44;display:none;';
  panel.innerHTML = '<strong>PRODUCTION RUNTIME STATUS</strong><div data-content style="margin-top:9px;color:#9ab3c5">Waiting for authenticated session.</div>';
  document.body.appendChild(panel);
  return panel;
}

async function refreshRuntimeStatus() {
  const panel = document.getElementById('runtime-status-panel');
  const content = panel?.querySelector('[data-content]');
  if (!panel || !content || !window.janusRuntime.hasSession()) return;
  panel.style.display = 'block';
  content.textContent = 'Loading protected runtime status...';
  try {
    const user = await window.janusRuntime.me();
    const values = await Promise.allSettled([
      window.janusRuntime.engagements(),
      window.janusRuntime.licenseStatus(),
      window.janusRuntime.auditLogs(),
    ]);
    const valueOr = (index, fallback) => values[index].status === 'fulfilled' ? values[index].value : fallback;
    const engagements = valueOr(0, []);
    const license = valueOr(1, null);
    const audits = valueOr(2, []);
    content.replaceChildren();
    const lines = [
      `USER: ${user.email}`,
      `ROLE: ${user.role}`,
      `ORG: ${user.organization_id}`,
      `LICENSE: ${license ? `${license.plan} · expires ${new Date(license.expires_at).toLocaleDateString()}` : 'not available for this role'}`,
      `ENGAGEMENTS: ${engagements.length}`,
      `RECENT AUDIT EVENTS: ${audits.length}`,
    ];
    lines.forEach(line => { const div = document.createElement('div'); div.textContent = line; div.style.margin = '3px 0'; content.appendChild(div); });
    const refresh = document.createElement('button');
    refresh.type = 'button'; refresh.textContent = 'REFRESH'; refresh.style.marginTop = '8px';
    refresh.addEventListener('click', refreshRuntimeStatus); content.appendChild(refresh);
  } catch (error) {
    content.textContent = `Runtime status unavailable: ${error.message}`;
  }
}

document.addEventListener('DOMContentLoaded', createRuntimeStatusPanel);
window.addEventListener('janus:session', refreshRuntimeStatus);
