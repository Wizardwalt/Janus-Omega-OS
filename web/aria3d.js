/* ═══════════════════════════════════════════════════════════════════════════
   ARIA 3D AVATAR ENGINE — Human-Like Edition
   Realistic human proportions · Skin tones · Canvas tattoo textures
   Holographic aura overlay (she's human in form, digital in nature)
   ═══════════════════════════════════════════════════════════════════════════ */
'use strict';

class AriaAvatar3D {
  constructor(canvas, options = {}) {
    this.canvas  = canvas;
    this.opts    = Object.assign({
      skinColor:    0xE8A87C,
      lipColor:     0xAA7755,
      eyeColor:     0x00CCFF,
      hairColor:    0x1A0A00,
      outfitAccent: 0x00FF41,
      glowColor:    0x9D00FF,
      hairStyle:    'long',
      outfit:       'tactical',
      glowIntensity: 1.0,
      style:        'human',
      height:       1.0,
      mood:         'neutral',
      tattoos:      [],
    }, options);

    this.clock      = new THREE.Clock();
    this.parts      = {};
    this.armCanvases = {};
    this.speaking   = false;
    this.mood       = this.opts.mood;
    this._disposed  = false;
    this.projecting = false;
    this.rings      = [];
    this.particles  = null;
    this.particleVels = [];
    this.particlePos  = null;

    this._initScene();
    this._buildAvatar();
    this._buildEnvironment();
    this._buildAura();
    this._applyAllTattoos();
    this._startLoop();
  }

  // ─── Scene ─────────────────────────────────────────────────────────────────
  _initScene() {
    const W = this.canvas.clientWidth  || 400;
    const H = this.canvas.clientHeight || 600;

    this.scene  = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(42, W / H, 0.1, 200);
    this.camera.position.set(0, 1.65, 3.8);
    this.camera.lookAt(0, 1.5, 0);

    this.renderer = new THREE.WebGLRenderer({ canvas: this.canvas, antialias: true, alpha: true });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setSize(W, H);
    this.renderer.setClearColor(0x000000, 0);
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    // Lighting — warm key, cool fill, rim
    const ambient = new THREE.AmbientLight(0x222233, 0.7);
    this.scene.add(ambient);

    this.keyLight = new THREE.SpotLight(0xFFEEDD, 2.2, 10, Math.PI * 0.35, 0.5);
    this.keyLight.position.set(-1.5, 4, 3);
    this.keyLight.castShadow = true;
    this.scene.add(this.keyLight);
    this.scene.add(this.keyLight.target);

    this.fillLight = new THREE.PointLight(0x8899FF, 0.9, 8);
    this.fillLight.position.set(2, 2, 1);
    this.scene.add(this.fillLight);

    this.rimLight = new THREE.PointLight(0x9D00FF, 1.2, 6);
    this.rimLight.position.set(0, 2.5, -2);
    this.scene.add(this.rimLight);

    this.glowLight = new THREE.PointLight(this.opts.glowColor, 0.6 * this.opts.glowIntensity, 3);
    this.glowLight.position.set(0, 1.8, 1.5);
    this.scene.add(this.glowLight);

    this._resizeObs = new ResizeObserver(() => this._onResize());
    this._resizeObs.observe(this.canvas.parentElement || document.body);
  }

  _onResize() {
    if (!this.canvas.parentElement) return;
    const W = this.canvas.parentElement.clientWidth  || this.canvas.width;
    const H = this.canvas.parentElement.clientHeight || this.canvas.height;
    if (W < 10 || H < 10) return;
    this.camera.aspect = W / H;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(W, H);
  }

  // ─── Material helpers ──────────────────────────────────────────────────────
  _skinMat(extra = {}) {
    return new THREE.MeshStandardMaterial({
      color: this.opts.skinColor, roughness: 0.75, metalness: 0.0, ...extra,
    });
  }

  _hairMat() {
    return new THREE.MeshStandardMaterial({
      color: this.opts.hairColor, roughness: 0.85, metalness: 0.04,
    });
  }

  _eyeWhiteMat() {
    return new THREE.MeshStandardMaterial({ color: 0xF5F3EE, roughness: 0.3 });
  }

  _irisMat() {
    return new THREE.MeshStandardMaterial({
      color: this.opts.eyeColor, roughness: 0.15,
      emissive: this.opts.eyeColor,
      emissiveIntensity: 0.25 * this.opts.glowIntensity,
    });
  }

  _lipMat() {
    return new THREE.MeshStandardMaterial({ color: this.opts.lipColor, roughness: 0.55 });
  }

  _accentMat(extra = {}) {
    return new THREE.MeshStandardMaterial({
      color: this.opts.outfitAccent, roughness: 0.3, metalness: 0.4,
      emissive: this.opts.outfitAccent, emissiveIntensity: 0.15 * this.opts.glowIntensity,
      ...extra,
    });
  }

  _bodyMat(color = 0x222233) {
    return new THREE.MeshStandardMaterial({ color, roughness: 0.6, metalness: 0.1 });
  }

  // ─── Canvas texture for tattooed body parts ────────────────────────────────
  _makeBodyCanvas(skinHex, w = 512, h = 512) {
    const c = document.createElement('canvas');
    c.width = w; c.height = h;
    const ctx = c.getContext('2d');
    ctx.fillStyle = skinHex || '#E8A87C';
    ctx.fillRect(0, 0, w, h);
    // Subtle shading gradient
    const g = ctx.createLinearGradient(0, 0, w, h);
    g.addColorStop(0, 'rgba(0,0,0,0)');
    g.addColorStop(1, 'rgba(0,0,0,0.08)');
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, w, h);
    return { canvas: c, ctx, texture: new THREE.CanvasTexture(c) };
  }

  _skinMatWithCanvas(canvasObj) {
    return new THREE.MeshStandardMaterial({
      map: canvasObj.texture, roughness: 0.75, metalness: 0.0,
    });
  }

  // ─── Build full avatar ─────────────────────────────────────────────────────
  _buildAvatar() {
    this.avatarGroup = new THREE.Group();
    this.avatarGroup.scale.setScalar(this.opts.height);
    this.scene.add(this.avatarGroup);

    this._buildHead();
    this._buildNeck();
    this._buildTorso();
    this._buildOutfit();
    this._buildArms();
    this._buildLegs();
  }

  // ─── HEAD ──────────────────────────────────────────────────────────────────
  _buildHead() {
    this.headGroup = new THREE.Group();
    this.headGroup.position.set(0, 3.05, 0);
    this.avatarGroup.add(this.headGroup);

    // Skull — slightly ovoid
    const skullGeo = new THREE.SphereGeometry(0.37, 32, 32);
    const skull = new THREE.Mesh(skullGeo, this._skinMat());
    skull.scale.set(0.96, 1.1, 0.93);
    skull.castShadow = true;
    this.headGroup.add(skull);
    this.parts.skull = skull;

    this._buildEyes();
    this._buildEyebrows();
    this._buildNose();
    this._buildLips();
    this._buildEars();
    this._buildHair();
  }

  _buildEyes() {
    [[-0.125, 1], [0.125, -1]].forEach(([x, side]) => {
      const eyeG = new THREE.Group();
      eyeG.position.set(x, 0.06, 0.33);
      this.headGroup.add(eyeG);

      // Sclera (white)
      const sclera = new THREE.Mesh(
        new THREE.SphereGeometry(0.07, 18, 18),
        this._eyeWhiteMat()
      );
      sclera.scale.set(1, 0.92, 0.52);
      eyeG.add(sclera);

      // Iris disc
      const irisMat = this._irisMat();
      const iris = new THREE.Mesh(new THREE.CircleGeometry(0.042, 24), irisMat);
      iris.position.z = 0.037;
      eyeG.add(iris);
      side > 0 ? (this.parts.irisL = iris) : (this.parts.irisR = iris);

      // Pupil
      const pupil = new THREE.Mesh(
        new THREE.CircleGeometry(0.02, 16),
        new THREE.MeshBasicMaterial({ color: 0x050508 })
      );
      pupil.position.z = 0.039;
      eyeG.add(pupil);

      // Highlight (specular dot)
      const highlight = new THREE.Mesh(
        new THREE.CircleGeometry(0.008, 10),
        new THREE.MeshBasicMaterial({ color: 0xFFFFFF })
      );
      highlight.position.set(0.014, 0.014, 0.04);
      eyeG.add(highlight);

      // Upper eyelid
      const lidMat = this._skinMat({ color: new THREE.Color(this.opts.skinColor).lerp(new THREE.Color(0x000000), 0.06).getHex() });
      const lid = new THREE.Mesh(
        new THREE.TorusGeometry(0.046, 0.009, 8, 28, Math.PI),
        lidMat
      );
      lid.position.z = 0.034;
      lid.rotation.z = Math.PI;
      eyeG.add(lid);

      // Eye inner glow light
      const eyeLight = new THREE.PointLight(this.opts.eyeColor, 0.18 * this.opts.glowIntensity, 0.7);
      eyeG.add(eyeLight);
      side > 0 ? (this.parts.eyeLGroup = eyeG) : (this.parts.eyeRGroup = eyeG);
    });
  }

  _buildEyebrows() {
    const browColor = new THREE.Color(this.opts.hairColor);
    const browMat = new THREE.MeshStandardMaterial({ color: browColor, roughness: 0.9 });

    [[-0.125, -0.12], [0.125, 0.12]].forEach(([x, rotZ]) => {
      const brow = new THREE.Mesh(
        new THREE.CapsuleGeometry(0.006, 0.085, 4, 8),
        browMat
      );
      brow.position.set(x, 0.18, 0.33);
      brow.rotation.z = rotZ;
      brow.rotation.x = -0.18;
      this.headGroup.add(brow);
    });
  }

  _buildNose() {
    // Nose bridge
    const bridge = new THREE.Mesh(
      new THREE.CapsuleGeometry(0.012, 0.08, 6, 8),
      this._skinMat()
    );
    bridge.position.set(0, -0.04, 0.35);
    bridge.rotation.x = 0.3;
    this.headGroup.add(bridge);

    // Nose tip
    const tip = new THREE.Mesh(
      new THREE.SphereGeometry(0.026, 14, 14),
      this._skinMat()
    );
    tip.position.set(0, -0.12, 0.4);
    this.headGroup.add(tip);

    // Nostrils
    [-0.03, 0.03].forEach(x => {
      const wing = new THREE.Mesh(
        new THREE.SphereGeometry(0.018, 10, 10),
        this._skinMat()
      );
      wing.scale.set(0.85, 0.7, 0.65);
      wing.position.set(x, -0.14, 0.385);
      this.headGroup.add(wing);
    });
  }

  _buildLips() {
    const lipMat = this._lipMat();

    // Upper lip
    const upperLip = new THREE.Mesh(
      new THREE.SphereGeometry(0.055, 16, 10),
      lipMat
    );
    upperLip.scale.set(1.1, 0.42, 0.45);
    upperLip.position.set(0, -0.21, 0.39);
    this.headGroup.add(upperLip);

    // Lower lip (fuller)
    const lowerLip = new THREE.Mesh(
      new THREE.SphereGeometry(0.052, 16, 10),
      lipMat.clone()
    );
    lowerLip.scale.set(1.0, 0.5, 0.5);
    lowerLip.position.set(0, -0.255, 0.39);
    this.headGroup.add(lowerLip);
    this.parts.lowerLip = lowerLip;

    // Mouth crease line
    const crease = new THREE.Mesh(
      new THREE.CapsuleGeometry(0.002, 0.09, 4, 8),
      new THREE.MeshBasicMaterial({ color: new THREE.Color(this.opts.lipColor).lerp(new THREE.Color(0), 0.4).getHex() })
    );
    crease.rotation.z = Math.PI / 2;
    crease.position.set(0, -0.232, 0.4);
    this.headGroup.add(crease);
    this.parts.mouthCrease = crease;
  }

  _buildEars() {
    const skinMat = this._skinMat();
    [-0.4, 0.4].forEach(x => {
      const ear = new THREE.Mesh(
        new THREE.SphereGeometry(0.065, 14, 12),
        skinMat.clone()
      );
      ear.scale.set(0.38, 0.75, 0.55);
      ear.position.set(x, 0.03, -0.01);
      this.headGroup.add(ear);
      // Inner ear bowl (darker)
      const inner = new THREE.Mesh(
        new THREE.SphereGeometry(0.04, 10, 8),
        this._skinMat({ color: new THREE.Color(this.opts.skinColor).lerp(new THREE.Color(0), 0.18).getHex() })
      );
      inner.scale.set(0.25, 0.5, 0.35);
      inner.position.copy(ear.position);
      this.headGroup.add(inner);
    });
  }

  _buildHair() {
    if (this.hairGroup) {
      this.hairGroup.children.forEach(c => c.geometry?.dispose());
      this.hairGroup.clear();
    } else {
      this.hairGroup = new THREE.Group();
      this.headGroup.add(this.hairGroup);
    }
    if (this.opts.hairStyle === 'none') return;
    const hm = this._hairMat();

    // Top cap — always present
    const cap = new THREE.Mesh(
      new THREE.SphereGeometry(0.38, 24, 18, 0, Math.PI*2, 0, Math.PI*0.5),
      hm
    );
    cap.position.y = 0.07;
    this.hairGroup.add(cap);

    if (this.opts.hairStyle === 'long') {
      // Back mass
      const back = new THREE.Mesh(
        new THREE.CylinderGeometry(0.28, 0.14, 1.4, 18, 1, true),
        hm.clone()
      );
      back.position.set(0, -0.85, -0.08);
      this.hairGroup.add(back);
      // Side strands
      [-0.35, 0.35].forEach((x, i) => {
        const strand = new THREE.Mesh(
          new THREE.CylinderGeometry(0.09, 0.03, 1.1, 10),
          hm.clone()
        );
        strand.position.set(x * 1.1, -0.52, 0.05);
        strand.rotation.z = x * 0.28;
        this.hairGroup.add(strand);
      });
      // Front fringe
      for (let i = 0; i < 4; i++) {
        const fringe = new THREE.Mesh(
          new THREE.CylinderGeometry(0.042, 0.015, 0.32, 8),
          hm.clone()
        );
        fringe.position.set(-0.18 + i * 0.12, 0.05, 0.33);
        fringe.rotation.x = 0.55 + (i % 2) * 0.1;
        this.hairGroup.add(fringe);
      }
    } else if (this.opts.hairStyle === 'short') {
      const shortCap = new THREE.Mesh(
        new THREE.SphereGeometry(0.39, 22, 16, 0, Math.PI*2, 0, Math.PI*0.65),
        hm.clone()
      );
      shortCap.position.y = 0.04;
      this.hairGroup.add(shortCap);
    } else if (this.opts.hairStyle === 'bun') {
      const bun = new THREE.Mesh(new THREE.SphereGeometry(0.15, 16, 14), hm.clone());
      bun.scale.set(1, 0.75, 1);
      bun.position.set(0, 0.46, -0.12);
      this.hairGroup.add(bun);
      const band = new THREE.Mesh(
        new THREE.TorusGeometry(0.13, 0.018, 8, 24),
        this._accentMat()
      );
      band.position.copy(bun.position);
      band.rotation.x = Math.PI/2;
      this.hairGroup.add(band);
    } else if (this.opts.hairStyle === 'pixie') {
      const pixie = new THREE.Mesh(
        new THREE.SphereGeometry(0.39, 20, 16, 0, Math.PI*2, 0, Math.PI*0.55),
        hm.clone()
      );
      pixie.position.y = 0.06;
      this.hairGroup.add(pixie);
      // Short tufts
      for (let i = 0; i < 5; i++) {
        const tuft = new THREE.Mesh(
          new THREE.SphereGeometry(0.06, 8, 8),
          hm.clone()
        );
        tuft.position.set(-0.15 + i*0.075, 0.38, 0.12 + (i%2)*0.05);
        this.hairGroup.add(tuft);
      }
    }
  }

  // ─── NECK ──────────────────────────────────────────────────────────────────
  _buildNeck() {
    const neck = new THREE.Mesh(
      new THREE.CylinderGeometry(0.1, 0.115, 0.28, 14),
      this._skinMat()
    );
    neck.position.set(0, 2.73, 0);
    this.avatarGroup.add(neck);
    this.parts.neck = neck;
  }

  // ─── TORSO ─────────────────────────────────────────────────────────────────
  _buildTorso() {
    this.torsoGroup = new THREE.Group();
    this.torsoGroup.position.set(0, 2.18, 0);
    this.avatarGroup.add(this.torsoGroup);

    // Upper chest
    const chestGeo = new THREE.CylinderGeometry(0.27, 0.24, 0.55, 18);
    this.chestCanvas = this._makeBodyCanvas(this._skinHex());
    const chestMat = this._skinMatWithCanvas(this.chestCanvas);
    const chest = new THREE.Mesh(chestGeo, chestMat);
    chest.castShadow = true;
    this.torsoGroup.add(chest);
    this.parts.chest = chest;
    this.armCanvases['chest'] = this.chestCanvas;

    // Clavicle line
    [-0.14, 0.14].forEach(x => {
      const clavLine = new THREE.Mesh(
        new THREE.CapsuleGeometry(0.005, 0.2, 4, 6),
        this._skinMat({ color: new THREE.Color(this.opts.skinColor).lerp(new THREE.Color(0), 0.1).getHex() })
      );
      clavLine.rotation.z = x > 0 ? 0.5 : -0.5;
      clavLine.position.set(x * 1.2, 0.22, 0.2);
      this.torsoGroup.add(clavLine);
    });

    // Outfit overlay on top
    const outfitTopGeo = new THREE.CylinderGeometry(0.275, 0.245, 0.56, 18);
    const outfitTopMat = this._bodyMat(0x111118);
    outfitTopMat.transparent = true;
    outfitTopMat.opacity = (this.opts.outfit === 'casual') ? 0.85 : 0.72;
    const outfitTop = new THREE.Mesh(outfitTopGeo, outfitTopMat);
    this.torsoGroup.add(outfitTop);

    // Tech-panel accent (chest plate for tactical)
    if (this.opts.outfit === 'tactical' || this.opts.outfit === 'armor') {
      const plate = new THREE.Mesh(
        new THREE.BoxGeometry(0.22, 0.3, 0.06),
        this._bodyMat(0x1A1A22)
      );
      plate.position.set(0, 0.06, 0.27);
      this.torsoGroup.add(plate);
      // Accent strip
      const strip = new THREE.Mesh(
        new THREE.BoxGeometry(0.18, 0.025, 0.065),
        this._accentMat()
      );
      strip.position.set(0, 0.2, 0.27);
      this.torsoGroup.add(strip);
      this.parts.accentStrip = strip;
    }
  }

  // ─── OUTFIT lower body ─────────────────────────────────────────────────────
  _buildOutfit() {
    this.outfitGroup = new THREE.Group();
    this.avatarGroup.add(this.outfitGroup);
    const darkMat = this._bodyMat(0x111118);
    const acMat   = this._accentMat();

    // Hip
    const hip = new THREE.Mesh(
      new THREE.CylinderGeometry(0.26, 0.24, 0.3, 16),
      darkMat.clone()
    );
    hip.position.set(0, 1.82, 0);
    this.outfitGroup.add(hip);

    // Belt
    const belt = new THREE.Mesh(
      new THREE.CylinderGeometry(0.255, 0.255, 0.045, 24),
      acMat.clone()
    );
    belt.position.set(0, 1.98, 0);
    this.outfitGroup.add(belt);

    if (this.opts.outfit === 'robe') {
      const robe = new THREE.Mesh(
        new THREE.ConeGeometry(0.55, 1.7, 18, 1, true),
        this._bodyMat(0x0D0D18)
      );
      robe.position.set(0, 1.25, 0);
      this.outfitGroup.add(robe);
    } else {
      // Tactical/casual legs (pants)
      const pantsGeo = new THREE.CylinderGeometry(0.235, 0.21, 0.65, 14);
      this.outfitGroup.add(new THREE.Mesh(pantsGeo, darkMat.clone()).translateY(1.55));

      // Thigh detail (armor panel)
      if (this.opts.outfit === 'armor') {
        [-0.14, 0.14].forEach(x => {
          const panel = new THREE.Mesh(
            new THREE.BoxGeometry(0.13, 0.25, 0.07),
            this._bodyMat(0x1A1A22)
          );
          panel.position.set(x, 1.62, 0.15);
          this.outfitGroup.add(panel);
          const panelAccent = new THREE.Mesh(
            new THREE.BoxGeometry(0.1, 0.02, 0.075),
            acMat.clone()
          );
          panelAccent.position.set(x, 1.75, 0.15);
          this.outfitGroup.add(panelAccent);
        });
      }
    }
  }

  // ─── ARMS ──────────────────────────────────────────────────────────────────
  _buildArms() {
    // Canvas textures for tattooing
    this.armLCanvas = this._makeBodyCanvas(this._skinHex());
    this.armRCanvas = this._makeBodyCanvas(this._skinHex());
    this.armCanvases['arm_left']  = this.armLCanvas;
    this.armCanvases['arm_right'] = this.armRCanvas;

    const armLMat = this._skinMatWithCanvas(this.armLCanvas);
    const armRMat = this._skinMatWithCanvas(this.armRCanvas);

    [['armLGroup', -0.42, armLMat, this.armLCanvas],
     ['armRGroup',  0.42, armRMat, this.armRCanvas]].forEach(([key, x, mat, cv]) => {
      const grp = new THREE.Group();
      grp.position.set(x, 2.5, 0);
      this.avatarGroup.add(grp);
      this.parts[key] = grp;

      // Shoulder cap
      const shoulder = new THREE.Mesh(
        new THREE.SphereGeometry(0.135, 14, 12),
        this._skinMat()
      );
      shoulder.position.y = 0.05;
      grp.add(shoulder);

      // Upper arm
      const upperArm = new THREE.Mesh(
        new THREE.CylinderGeometry(0.075, 0.068, 0.55, 14),
        mat
      );
      upperArm.position.y = -0.28;
      grp.add(upperArm);

      // Elbow
      const elbow = new THREE.Mesh(
        new THREE.SphereGeometry(0.072, 12, 10),
        this._skinMat()
      );
      elbow.position.y = -0.57;
      grp.add(elbow);

      // Forearm group
      const faGrp = new THREE.Group();
      faGrp.position.y = -0.57;
      grp.add(faGrp);
      key === 'armLGroup' ? (this.parts.fArmLGroup = faGrp) : (this.parts.fArmRGroup = faGrp);

      const forearm = new THREE.Mesh(
        new THREE.CylinderGeometry(0.065, 0.055, 0.5, 14),
        mat.clone()
      );
      forearm.position.y = -0.26;
      faGrp.add(forearm);

      // Wrist
      const wrist = new THREE.Mesh(
        new THREE.SphereGeometry(0.058, 12, 10),
        this._skinMat()
      );
      wrist.position.y = -0.52;
      faGrp.add(wrist);

      // Hand (mitten with thumb)
      const hand = new THREE.Mesh(
        new THREE.SphereGeometry(0.068, 12, 10),
        this._skinMat()
      );
      hand.scale.set(0.85, 0.7, 0.65);
      hand.position.y = -0.62;
      faGrp.add(hand);

      const thumb = new THREE.Mesh(
        new THREE.CapsuleGeometry(0.022, 0.055, 4, 8),
        this._skinMat()
      );
      thumb.position.set(x > 0 ? 0.06 : -0.06, -0.64, 0.04);
      thumb.rotation.z = x > 0 ? 0.6 : -0.6;
      faGrp.add(thumb);

      // Outfit sleeve overlay
      if (this.opts.outfit !== 'casual') {
        const sleeve = new THREE.Mesh(
          new THREE.CylinderGeometry(0.078, 0.07, 0.54, 14),
          this._bodyMat(0x111118)
        );
        sleeve.material.transparent = true;
        sleeve.material.opacity = 0.75;
        sleeve.position.y = -0.28;
        grp.add(sleeve);
        // Wrist accent cuff
        const cuff = new THREE.Mesh(
          new THREE.CylinderGeometry(0.07, 0.068, 0.04, 16),
          this._accentMat()
        );
        cuff.position.set(0, -0.54, 0);
        faGrp.add(cuff);
      }
    });
  }

  // ─── LEGS ──────────────────────────────────────────────────────────────────
  _buildLegs() {
    this.legsGroup = new THREE.Group();
    this.avatarGroup.add(this.legsGroup);

    const darkMat  = this._bodyMat(0x111118);
    const acMat    = this._accentMat();

    [[-0.155, 'legL'], [0.155, 'legR']].forEach(([x, key]) => {
      const lGrp = new THREE.Group();
      lGrp.position.set(x, 1.6, 0);
      this.legsGroup.add(lGrp);
      this.parts[key] = lGrp;

      // Thigh
      const thigh = new THREE.Mesh(
        new THREE.CylinderGeometry(0.1, 0.088, 0.72, 14),
        darkMat.clone()
      );
      thigh.position.y = -0.36;
      lGrp.add(thigh);

      // Knee
      const knee = new THREE.Mesh(
        new THREE.SphereGeometry(0.092, 12, 10),
        this._bodyMat(0x151520)
      );
      knee.position.y = -0.75;
      lGrp.add(knee);

      // Shin
      const shin = new THREE.Mesh(
        new THREE.CylinderGeometry(0.082, 0.07, 0.68, 14),
        darkMat.clone()
      );
      shin.position.y = -1.12;
      lGrp.add(shin);

      // Ankle accent ring
      const ankle = new THREE.Mesh(
        new THREE.TorusGeometry(0.08, 0.014, 8, 20),
        acMat.clone()
      );
      ankle.rotation.x = Math.PI/2;
      ankle.position.y = -1.5;
      lGrp.add(ankle);

      // Boot
      const boot = new THREE.Mesh(
        new THREE.BoxGeometry(0.16, 0.14, 0.32),
        this._bodyMat(0x0C0C14)
      );
      boot.position.set(0, -1.59, 0.05);
      lGrp.add(boot);

      // Boot toe cap
      const toeCap = new THREE.Mesh(
        new THREE.SphereGeometry(0.075, 10, 8),
        this._bodyMat(0x1A1A24)
      );
      toeCap.scale.set(1, 0.6, 1.1);
      toeCap.position.set(0, -1.59, 0.19);
      lGrp.add(toeCap);
    });
  }

  // ─── Holographic AURA (particles + rings — she's a digital being) ──────────
  _buildAura() {
    // Floating particles around body
    const count = 280;
    const pos   = new Float32Array(count * 3);
    const vels  = [];
    for (let i = 0; i < count; i++) {
      const r     = 0.45 + Math.random() * 1.0;
      const theta = Math.random() * Math.PI * 2;
      const phi   = Math.random() * Math.PI;
      pos[i*3]   = r * Math.sin(phi) * Math.cos(theta);
      pos[i*3+1] = 0.2 + Math.random() * 3.0;
      pos[i*3+2] = r * Math.sin(phi) * Math.sin(theta);
      vels.push({ vx: (Math.random()-.5)*.002, vy: (Math.random()-.5)*.003+.001, vz: (Math.random()-.5)*.002, oy: pos[i*3+1] });
    }
    const geo = new THREE.BufferGeometry();
    geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
    this.particles    = new THREE.Points(geo, new THREE.PointsMaterial({
      color: this.opts.glowColor || 0x9D00FF, size: 0.016, transparent: true, opacity: 0.55, sizeAttenuation: true,
    }));
    this.particleVels = vels;
    this.particlePos  = pos;
    this.scene.add(this.particles);

    // Subtle orbit rings
    [[0.7, 0.3, 0.6], [0.95, -0.5, 0.4], [1.2, 0.9, 0.25]].forEach(([r, tilt, spd]) => {
      const ring = new THREE.Mesh(
        new THREE.TorusGeometry(r, 0.008, 6, 72),
        new THREE.MeshBasicMaterial({ color: this.opts.glowColor || 0x9D00FF, transparent: true, opacity: 0.28 })
      );
      ring.position.y = 1.75;
      ring.rotation.x = tilt;
      ring._speed = spd;
      this.scene.add(ring);
      this.rings.push(ring);
    });
  }

  // ─── Floor environment ─────────────────────────────────────────────────────
  _buildEnvironment() {
    const gc  = this.opts.glowColor || 0x9D00FF;
    const gc2 = this.opts.outfitAccent || 0x00FF41;

    // Shadow receiver disc
    const floor = new THREE.Mesh(
      new THREE.CircleGeometry(2.5, 64),
      new THREE.MeshStandardMaterial({ color: 0x080810, roughness: 0.9 })
    );
    floor.rotation.x = -Math.PI/2;
    floor.receiveShadow = true;
    this.scene.add(floor);

    // Glow disc
    const gdisc = new THREE.Mesh(
      new THREE.CircleGeometry(1.6, 64),
      new THREE.MeshBasicMaterial({ color: gc, transparent: true, opacity: 0.05, side: THREE.DoubleSide })
    );
    gdisc.rotation.x = -Math.PI/2;
    gdisc.position.y = 0.005;
    this.scene.add(gdisc);

    // Outer accent ring
    const outerRing = new THREE.Mesh(
      new THREE.RingGeometry(1.4, 1.55, 72),
      new THREE.MeshBasicMaterial({ color: gc2, transparent: true, opacity: 0.3, side: THREE.DoubleSide })
    );
    outerRing.rotation.x = -Math.PI/2;
    outerRing.position.y = 0.008;
    this.scene.add(outerRing);
    this.parts.floorRing = outerRing;

    // Inner spinning ring
    const innerRing = new THREE.Mesh(
      new THREE.RingGeometry(0.8, 0.92, 56),
      new THREE.MeshBasicMaterial({ color: gc, transparent: true, opacity: 0.2, side: THREE.DoubleSide })
    );
    innerRing.rotation.x = -Math.PI/2;
    innerRing.position.y = 0.01;
    this.scene.add(innerRing);
    this.parts.innerRing = innerRing;

    // Grid
    const grid = new THREE.GridHelper(6, 14, gc, gc);
    grid.material.transparent = true;
    grid.material.opacity = 0.05;
    this.scene.add(grid);
  }

  // ─── Skin hex helper ────────────────────────────────────────────────────────
  _skinHex() {
    return '#' + this.opts.skinColor.toString(16).padStart(6, '0');
  }

  // ─── Tattoo application ────────────────────────────────────────────────────
  _applyAllTattoos() {
    if (!this.opts.tattoos) return;
    this.opts.tattoos.forEach(t => this._applyTattooToCanvas(t));
  }

  _applyTattooToCanvas(tattoo) {
    const cvObj = this.armCanvases[tattoo.details?.location];
    if (!cvObj) return;
    const { ctx, canvas, texture } = cvObj;
    const cx = (tattoo.details?.posX ?? 0.5) * canvas.width;
    const cy = (tattoo.details?.posY ?? 0.5) * canvas.height;
    const sz = (tattoo.details?.size ?? 0.7) * 120;
    drawTattooDesign(ctx, tattoo.details?.design || 'circuit', tattoo.details?.color || '#00FF41', cx, cy, sz, tattoo.details?.text || '');
    texture.needsUpdate = true;
  }

  applyTattoo(mod) {
    this._applyTattooToCanvas(mod);
  }

  // ─── Animation loop ────────────────────────────────────────────────────────
  _startLoop() {
    const animate = () => {
      if (this._disposed) return;
      requestAnimationFrame(animate);
      this._tick();
    };
    animate();
  }

  _tick() {
    const dt = this.clock.getDelta();
    const t  = this.clock.getElapsedTime();
    this._animateBody(t);
    this._animateParticles();
    this._animateRings(t);
    this._animateLights(t);
    if (this.parts.innerRing) this.parts.innerRing.rotation.z += 0.008;
    this.renderer.render(this.scene, this.camera);
  }

  _animateBody(t) {
    const ms = { neutral:1, happy:1.6, curious:1.1, processing:0.9, sad:0.5, excited:2.2 }[this.mood] ?? 1;

    // Breathing
    if (this.torsoGroup) this.torsoGroup.scale.y = 1 + Math.sin(t * 1.3 * ms) * 0.015;

    // Head bob + look-around
    if (this.headGroup) {
      this.headGroup.position.y = 3.05 + Math.sin(t * 1.3 * ms) * 0.01;
      this.headGroup.rotation.y = Math.sin(t * 0.35) * 0.09;
      this.headGroup.rotation.z = this.mood === 'curious' ? Math.sin(t * 0.7) * 0.1 : this.headGroup.rotation.z * 0.94;
    }

    // Speaking: head nod + mouth open
    if (this.speaking) {
      if (this.headGroup) this.headGroup.rotation.x = Math.sin(t * 7) * 0.06;
      if (this.parts.lowerLip) this.parts.lowerLip.position.y = -0.255 - Math.abs(Math.sin(t * 9)) * 0.02;
      // Eye glow pulses
      [this.parts.irisL, this.parts.irisR].forEach(iris => {
        if (iris) iris.material.emissiveIntensity = (0.5 + Math.sin(t * 8) * 0.3) * this.opts.glowIntensity;
      });
    } else {
      if (this.headGroup) this.headGroup.rotation.x *= 0.9;
      if (this.parts.lowerLip) this.parts.lowerLip.position.y += (-0.255 - this.parts.lowerLip.position.y) * 0.1;
      [this.parts.irisL, this.parts.irisR].forEach(iris => {
        if (iris) iris.material.emissiveIntensity = 0.22 * this.opts.glowIntensity;
      });
    }

    // Mood arm poses
    const lGrp = this.parts.armLGroup;
    const rGrp = this.parts.armRGroup;
    if (lGrp && rGrp) {
      if (this.mood === 'happy' || this.mood === 'excited') {
        lGrp.rotation.z = -0.45 + Math.sin(t * 2 * ms) * 0.12;
        rGrp.rotation.z =  0.45 + Math.sin(t * 2 * ms + 1) * 0.12;
      } else if (this.mood === 'processing') {
        lGrp.rotation.x = Math.sin(t * 1.4) * 0.08;
        rGrp.rotation.x = Math.cos(t * 1.4) * 0.08;
      } else {
        lGrp.rotation.z = Math.sin(t * 0.85) * 0.06 - 0.04;
        rGrp.rotation.z = -Math.sin(t * 0.85) * 0.06 + 0.04;
        lGrp.rotation.x = Math.sin(t * 0.45) * 0.03;
        rGrp.rotation.x = -Math.sin(t * 0.45) * 0.03;
      }
    }

    // Avatar float
    if (this.avatarGroup) {
      this.avatarGroup.position.y = Math.sin(t * 0.65) * 0.025;
      if (!this.projecting) this.avatarGroup.rotation.y = Math.sin(t * 0.16) * 0.1;
    }

    // Chest strip pulse
    if (this.parts.accentStrip) {
      this.parts.accentStrip.material.emissiveIntensity = (0.15 + Math.sin(t * 1.5 * ms) * 0.08) * this.opts.glowIntensity;
    }
  }

  _animateParticles() {
    if (!this.particles) return;
    const pos = this.particlePos;
    const vel = this.particleVels;
    const ms  = this.mood === 'processing' ? 2.5 : (this.mood === 'excited' ? 2 : 1);
    for (let i = 0; i < vel.length; i++) {
      pos[i*3]   += vel[i].vx * ms;
      pos[i*3+1] += vel[i].vy * ms;
      pos[i*3+2] += vel[i].vz * ms;
      if (pos[i*3+1] > vel[i].oy + 1.2) pos[i*3+1] = vel[i].oy - 0.3;
      const r = Math.sqrt(pos[i*3]*pos[i*3] + pos[i*3+2]*pos[i*3+2]);
      if (r > 1.6 || r < 0.3) { vel[i].vx *= -1; vel[i].vz *= -1; }
    }
    this.particles.geometry.attributes.position.needsUpdate = true;
    this.particles.rotation.y += 0.001 * (this.mood === 'excited' ? 2 : 1);
  }

  _animateRings(t) {
    this.rings.forEach(ring => {
      ring.rotation.y += ring._speed * 0.008;
      ring.rotation.z += ring._speed * 0.003;
    });
  }

  _animateLights(t) {
    const gi  = this.opts.glowIntensity;
    const ms  = this.mood === 'excited' ? 2 : 1;
    const p   = Math.sin(t * 1.6 * ms) * 0.4 + 1;
    if (this.glowLight) this.glowLight.intensity = 0.6 * gi * p;
    if (this.rimLight)  this.rimLight.intensity  = 1.2 * (0.7 + Math.sin(t * 0.9) * 0.3);
  }

  // ─── Public API ────────────────────────────────────────────────────────────
  speak(active = true) {
    this.speaking = active;
  }

  setMood(mood) {
    this.mood = mood;
    const moodGlow = { neutral: this.opts.glowColor, happy: 0xFFAA00, excited: 0xFF6600, curious: 0x00AAFF, processing: 0x9D00FF, sad: 0x3355AA };
    if (this.glowLight) this.glowLight.color.setHex(moodGlow[mood] ?? this.opts.glowColor);
  }

  customize(opts) {
    let needsRebuild = false;
    if (opts.hairStyle !== undefined && opts.hairStyle !== this.opts.hairStyle) { this.opts.hairStyle = opts.hairStyle; this._rebuildHair(); }
    if (opts.outfit    !== undefined && opts.outfit    !== this.opts.outfit)    { this.opts.outfit    = opts.outfit;    needsRebuild = true; }
    if (opts.height    !== undefined) { this.opts.height = opts.height; this.avatarGroup?.scale.setScalar(opts.height); }
    if (opts.glowIntensity !== undefined) this.opts.glowIntensity = opts.glowIntensity;
    if (opts.mood !== undefined) this.setMood(opts.mood);
  }

  _rebuildHair() {
    if (this.hairGroup) {
      this.hairGroup.children.forEach(c => c.geometry?.dispose());
      this.hairGroup.clear();
      this._buildHair();
    }
  }

  projectLifeSize(active = true) {
    this.projecting = active;
    if (active) {
      this.avatarGroup?.scale.setScalar(this.opts.height * 1.8);
      this.camera.position.set(0, 1.7, 7.5);
      this.camera.lookAt(0, 1.6, 0);
    } else {
      this.avatarGroup?.scale.setScalar(this.opts.height);
      this.camera.position.set(0, 1.65, 3.8);
      this.camera.lookAt(0, 1.5, 0);
    }
  }

  dispose() {
    this._disposed = true;
    this._resizeObs?.disconnect();
    this.renderer.dispose();
  }
}

window.AriaAvatar3D = AriaAvatar3D;
