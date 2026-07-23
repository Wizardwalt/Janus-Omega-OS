/* Organization-admin control panel backed only by protected runtime endpoints. */
'use strict';

function createRuntimeAdminPanel() {
  const panel = document.createElement('section');
  panel.id = 'runtime-admin-panel';
  panel.style.cssText = 'position:fixed;right:16px;top:16px;z-index:9998;width:min(430px,calc(100vw - 32px));max-height:70vh;overflow:auto;padding:12px;border:1px solid #c870ff;background:#13081a;color:#f1d8ff;font:11px monospace;display:none;';
  panel.innerHTML = '<strong>ORGANIZATION ADMINISTRATION</strong><div data-content style="margin-top:8px">Waiting for administrator session.</div>';
  document.body.appendChild(panel);
}

async function refreshRuntimeAdminPanel() {
  const panel = document.getElementById('runtime-admin-panel');
  const content = panel?.querySelector('[data-content]');
  if (!panel || !content) return;
  try {
    const user = await window.janusRuntime.me();
    if (user.role !== 'organization_admin') { panel.style.display = 'none'; return; }
    panel.style.display = 'block'; content.textContent = 'Loading organization administration data...';
    const [users, engagements, license] = await Promise.all([window.janusRuntime.users(), window.janusRuntime.engagements(), window.janusRuntime.licenseStatus()]);
    content.replaceChildren();
    addText(content, `LICENSE: ${license.plan} · ${license.enabled_features.join(', ')}`);
    addText(content, 'USERS:', true);
    users.forEach(user => {
      const row = document.createElement('div'); row.style.margin = '4px 0';
      row.textContent = `${user.email} · ${user.role} · ${user.active ? 'ACTIVE' : 'DISABLED'} `;
      const toggle = document.createElement('button'); toggle.textContent = user.active ? 'DISABLE' : 'ENABLE';
      toggle.addEventListener('click', async () => { try { await window.janusRuntime.setUserActive(user.user_id, !user.active); refreshRuntimeAdminPanel(); } catch (error) { alert(error.message); } });
      row.appendChild(toggle); content.appendChild(row);
    });
    addText(content, 'ENGAGEMENTS:', true);
    engagements.forEach(item => {
      const row = document.createElement('div'); row.style.margin = '4px 0';
      row.textContent = `${item.authorization_reference} · ${item.active ? 'ACTIVE' : 'DISABLED'} `;
      const toggle = document.createElement('button'); toggle.textContent = item.active ? 'DISABLE' : 'ENABLE';
      toggle.addEventListener('click', async () => { try { await window.janusRuntime.setEngagementActive(item.id, !item.active); refreshRuntimeAdminPanel(); } catch (error) { alert(error.message); } });
      row.appendChild(toggle); content.appendChild(row);
    });
  } catch (error) { content.textContent = `Administration unavailable: ${error.message}`; panel.style.display = 'block'; }
}
function addText(parent, text, title = false) { const div = document.createElement('div'); div.textContent = text; div.style.cssText = title ? 'margin-top:9px;color:#ffc7ff' : 'margin:3px 0'; parent.appendChild(div); }
document.addEventListener('DOMContentLoaded', createRuntimeAdminPanel);
window.addEventListener('janus:session', refreshRuntimeAdminPanel);
window.addEventListener('janus:logout', () => { const panel = document.getElementById('runtime-admin-panel'); if (panel) panel.style.display = 'none'; });
