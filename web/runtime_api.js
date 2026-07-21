/* Janus Runtime API client. Production views use this client instead of
   treating browser WebSocket output as proof that an operation ran. */
'use strict';

class JanusRuntimeApi {
  constructor() {
    this.baseUrl = localStorage.getItem('janus.runtimeUrl') || 'http://localhost:8080';
    this.token = sessionStorage.getItem('janus.sessionToken') || null;
  }

  setBaseUrl(url) {
    this.baseUrl = url.replace(/\/$/, '');
    localStorage.setItem('janus.runtimeUrl', this.baseUrl);
  }

  hasSession() { return Boolean(this.token); }

  async request(path, options = {}) {
    const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
    if (this.token) headers.Authorization = `Bearer ${this.token}`;
    const response = await fetch(`${this.baseUrl}${path}`, { ...options, headers });
    const body = await response.json().catch(() => ({ status: 'error', error: 'Invalid runtime response' }));
    if (!response.ok || body.status === 'error') {
      const error = new Error(body.error || `Runtime request failed (${response.status})`);
      error.status = response.status;
      throw error;
    }
    return body.data;
  }

  async bootstrap(organizationName, email, password) {
    return this.request('/auth/bootstrap', {
      method: 'POST', body: JSON.stringify({ organization_name: organizationName, email, password }),
    });
  }

  async login(email, password) {
    const session = await this.request('/auth/login', {
      method: 'POST', body: JSON.stringify({ email, password }),
    });
    this.token = session.session_token;
    sessionStorage.setItem('janus.sessionToken', this.token);
    return session;
  }

  async logout() {
    if (this.token) await this.request('/auth/logout', { method: 'POST' });
    this.token = null;
    sessionStorage.removeItem('janus.sessionToken');
  }

  me() { return this.request('/auth/me'); }
  engagements() { return this.request('/engagements'); }
  licenseStatus() { return this.request('/licenses/status'); }
  auditLogs() { return this.request('/audit/logs'); }
  plugins() { return this.request('/plugins'); }

  execute(plugin, engagementId, targetAsset, args = {}) {
    return this.request('/execute', {
      method: 'POST',
      body: JSON.stringify({ plugin, engagement_id: engagementId, target_asset: targetAsset, args }),
    });
  }
}

window.janusRuntime = new JanusRuntimeApi();
