#!/bin/bash
echo "=== FINAL COMPLETE FIX — Everything Updated ==="

mkdir -p website docs/hardware docs/software modules/legendary overseer scripts marketplace airootfs

# Beautiful Landing Page
cat > website/index.html << 'EOR'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Janus Omega OS • Pandora Titan</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');
    body { margin:0; background:#000; color:#00FF41; font-family:'VT323', monospace; }
    .crt { position:relative; width:100%; min-height:100vh; background:#001100; overflow:hidden; }
    .scanlines { position:absolute; top:0; left:0; right:0; bottom:0; background:repeating-linear-gradient(transparent 0px, transparent 2px, rgba(0,255,65,0.07) 2px, rgba(0,255,65,0.07) 4px); animation:flicker 0.12s infinite; }
    @keyframes flicker { 0%,100%{opacity:0.95;} 50%{opacity:1;} }
    .container { max-width:1100px; margin:0 auto; padding:40px 20px; text-align:center; }
    h1 { font-size:4.8rem; text-shadow:0 0 20px #00FF41; }
    button { background:#003300; color:#00FF41; border:3px solid #00FF41; padding:18px 42px; font-size:1.7rem; margin:12px; cursor:pointer; }
    button:hover { background:#00FF41; color:#000; }
  </style>
</head>
<body>
  <div class="crt">
    <div class="scanlines"></div>
    <div class="container">
      <h1>JANUS Ω OS</h1>
      <p>THE FOREARM-MOUNTED TACTICAL SINGULARITY</p>
      <button onclick="window.location.href='demo.html'">ENTER THE TITAN — LIVE DEMO</button>
      <button onclick="window.open('https://github.com/Wizardwalt/Janus-Omega-OS','_blank')">GITHUB REPO</button>
    </div>
  </div>
</body>
</html>
EOR

# Interactive Demo
cat > website/demo.html << 'EOR'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Pandora Titan Live Demo</title>
  <style>
    body { background:#000; color:#00FF41; font-family:'VT323', monospace; }
    #terminal { width:820px; height:520px; margin:40px auto; border:14px solid #222; background:#001100; box-shadow:0 0 60px #00FF41; position:relative; overflow:hidden; }
    .header { background:#002200; padding:10px; text-align:center; font-size:1.8rem; }
    .output { padding:20px; height:380px; overflow-y:auto; }
    button { background:#003300; color:#00FF41; border:2px solid #00FF41; padding:12px 24px; margin:8px; font-size:1.4rem; cursor:pointer; }
  </style>
</head>
<body>
  <div id="terminal">
    <div class="header">JANUS Ω OS v7.0 — OVERSEER ONLINE</div>
    <div class="output" id="output"></div>
    <div class="scanlines"></div>
  </div>

  <div style="text-align:center; margin-top:20px;">
    <button onclick="speakCommand('Overseer, plan a carrier unlock')">Carrier Liberation</button>
    <button onclick="speakCommand('Overseer, activate fear cascade')">Fear Cascade</button>
    <button onclick="speakCommand('Overseer, full network takeover')">Network Takeover</button>
  </div>

  <script>
    const output = document.getElementById('output');
    function addLine(text) {
      output.innerHTML += `<span style="color:#00AA00">[OVERSEER]</span> ${text}<br>`;
      output.scrollTop = output.scrollHeight;
    }
    function speakCommand(cmd) {
      addLine(`Voice command: "${cmd}"`);
      setTimeout(() => addLine("Executing... Mission in progress."), 600);
    }
    addLine("Overseer AI online. 1000 modules ready.");
  </script>
</body>
</html>
EOR

# Field Manual
cat > docs/FIELD-MANUAL.md << 'EOR'
# JANUS OS FIELD MANUAL — 1000-MODULE SINGULARITY
**VAULT-TEC APPROVED • PANDORA SERIES • v7.1 God Tier Codex**

**Total Modules: 1000**

**God Tier / Legendary Category (100 modules)** — The most powerful mythic tools.

**Signature God Tier Modules:**
- apotheosis.lua — Final ascension
- eternal_liberator.lua — Permanent freedom
- psyche_reaver.lua — Master psychological weapon
- reality_forge.lua — Rewrite reality
- overseer_ascension.lua — Operator and AI become one

**Usage:**
- `modules list`
- `overseer recommend`
- Triple haptic tap for God Tier modules

The Vault is eternal.
EOR

echo "✅ Full website and Field Manual updated."
