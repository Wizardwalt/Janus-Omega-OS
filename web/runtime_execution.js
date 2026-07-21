/* Production execution panel. Every request goes through the runtime gate. */
'use strict';

function createExecutionPanel() {
  const panel = document.createElement('section');
  panel.id = 'runtime-execution-panel';
  panel.style.cssText = 'position:fixed;left:16px;top:16px;z-index:9999;width:min(400px,calc(100vw - 32px));padding:12px;border:1px solid #ffb000;background:#171005;color:#fff1c9;font:11px monospace;box-shadow:0 0 20px #ffb00044;display:none;';
  panel.innerHTML = '<strong>AUTHORIZED PRODUCTION EXECUTION</strong><div data-content style="margin-top:8px">Sign in to load approved engagements.</div>';
  document.body.appendChild(panel);
  return panel;
}

async function loadProductionExecutionPanel() {
  const panel = document.getElementById('runtime-execution-panel');
  const content = panel?.querySelector('[data-content]');
  if (!panel || !content || !window.janusRuntime.hasSession()) return;
  panel.style.display = 'block'; content.textContent = 'Loading engagements and runtime plugins...';
  try {
    const user = await window.janusRuntime.me();
    if (!['organization_admin', 'operator'].includes(user.role)) {
      content.textContent = `Role ${user.role} cannot request production execution.`;
      return;
    }
    const [engagements, plugins] = await Promise.all([window.janusRuntime.engagements(), window.janusRuntime.plugins()]);
    const active = engagements.filter(item => item.active);
    content.replaceChildren();
    if (!active.length) { content.textContent = 'No active engagement exists. Production execution is unavailable.'; return; }
    const engagement = selectField('ENGAGEMENT', active.map(item => [item.id, `${item.authorization_reference} (${item.id})`]));
    const asset = selectField('APPROVED ASSET', active[0].scope.approved_assets.map(item => [item, item]));
    const plugin = selectField('PLUGIN', plugins.map(item => [item.id, `${item.name} · ${item.category} · ${item.status}`]));
    const result = document.createElement('div'); result.style.marginTop = '8px'; result.style.color = '#ffe29a';
    const execute = document.createElement('button'); execute.type = 'button'; execute.textContent = 'REQUEST AUTHORIZED EXECUTION'; execute.style.marginTop = '8px';
    const syncAssets = () => {
      const selected = active.find(item => item.id === engagement.value);
      asset.replaceChildren(...(selected?.scope.approved_assets || []).map(item => new Option(item, item)));
    };
    engagement.addEventListener('change', syncAssets);
    execute.addEventListener('click', async () => {
      execute.disabled = true; result.textContent = 'Submitting protected runtime request...';
      try {
        const output = await window.janusRuntime.execute(plugin.value, engagement.value, asset.value, {});
        result.textContent = `RUNTIME RESULT: ${JSON.stringify(output)}`;
      } catch (error) { result.textContent = `DENIED OR FAILED: ${error.message}`; }
      finally { execute.disabled = false; }
    });
    [engagement.wrapper, asset.wrapper, plugin.wrapper, execute, result].forEach(node => content.appendChild(node));
  } catch (error) { content.textContent = `Production panel unavailable: ${error.message}`; }
}

function selectField(label, options) {
  const wrapper = document.createElement('label'); wrapper.style.cssText = 'display:block;margin-top:7px'; wrapper.textContent = `${label}: `;
  const select = document.createElement('select'); select.style.maxWidth = '100%';
  options.forEach(([value, text]) => select.add(new Option(text, value)));
  wrapper.appendChild(select); select.wrapper = wrapper; return select;
}

document.addEventListener('DOMContentLoaded', createExecutionPanel);
window.addEventListener('janus:session', loadProductionExecutionPanel);

window.addEventListener('janus:logout', () => {
  const panel = document.getElementById('runtime-execution-panel');
  if (panel) panel.style.display = 'none';
});
