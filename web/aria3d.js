/* ═══════════════════════════════════════════════════════════════════════════
   ARIA 3D AVATAR ENGINE — Three.js holographic AI companion
   Full body · Procedural animations · Customisation · Life-size projection
   ═══════════════════════════════════════════════════════════════════════════ */

'use strict';

// ─── Three.js is loaded globally via CDN ──────────────────────────────────────
// Uses THREE global from the script tag in HTML

class AriaAvatar3D {
  constructor(canvas, options = {}) {
    this.canvas   = canvas;
    this.opts     = Object.assign({
      primaryColor:   0x9D00FF,
      secondaryColor: 0x00FF41,
      glowIntensity:  1.0,
      style:          'holographic',   // holographic | solid | wireframe | neon
      hairStyle:      'long',          // long | short | bun | none
      outfit:         'tactical',      // tactical | armor | casual | robe
      height:         1.0,
      mood:           'neutral',
    }, options);

    this.clock      = new THREE.Clock();
    this.mixers     = [];
    this.parts      = {};
    this.particles  = null;
    this.rings      = [];
    this.speaking   = false;
    this.mood       = this.opts.mood;
    this.moodTimer  = 0;
    this._disposed  = false;
    this.projecting = false;

    this._initScene();
    this._buildAvatar();
    this._buildEnvironment();
    this._buildParticles();
    this._buildHologramRings();
    this._startLoop();
  }

  // ─── Scene / Camera / Renderer ─────────────────────────────────────────────
  _initScene() {
    const W = this.canvas.clientWidth  || 400;
    const H = this.canvas.clientHeight || 600;

    this.scene    = new THREE.Scene();
    this.scene.fog = new THREE.FogExp2(0x000000, 0.08);

    this.camera = new THREE.PerspectiveCamera(45, W / H, 0.1, 200);
    this.camera.position.set(0, 1.6, 4.2);
    this.camera.lookAt(0, 1.4, 0);

    this.renderer = new THREE.WebGLRenderer({
      canvas:    this.canvas,
      antialias: true,
      alpha:     true,
    });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setSize(W, H);
    this.renderer.setClearColor(0x000000, 0);
    this.renderer.shadowMap.enabled = true;

    // Lights
    const ambient = new THREE.AmbientLight(0x111122, 0.6);
    this.scene.add(ambient);

    this.purpleLight = new THREE.PointLight(this.opts.primaryColor, 2.5, 8);
    this.purpleLight.position.set(0, 2, 1.5);
    this.scene.add(this.purpleLight);

    this.greenLight = new THREE.PointLight(this.opts.secondaryColor, 1.5, 6);
    this.greenLight.position.set(-1.5, 1, 1);
    this.scene.add(this.greenLight);

    this.rimLight = new THREE.PointLight(0x4488ff, 0.8, 5);
    this.rimLight.position.set(1.5, 2, -1);
    this.scene.add(this.rimLight);

    // Resize handler
    this._resizeObs = new ResizeObserver(() => this._onResize());
    this._resizeObs.observe(this.canvas.parentElement || document.body);
  }

  _onResize() {
    if (!this.canvas.parentElement) return;
    const W = this.canvas.parentElement.clientWidth;
    const H = this.canvas.parentElement.clientHeight;
    this.camera.aspect = W / H;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(W, H);
  }

  // ─── Material factory ──────────────────────────────────────────────────────
  _mat(colorHex, options = {}) {
    const gi = this.opts.glowIntensity;
    const base = {
      color:       colorHex,
      emissive:    colorHex,
      emissiveIntensity: options.emissive ?? (0.35 * gi),
      transparent: true,
      opacity:     options.opacity ?? (this.opts.style === 'holographic' ? 0.82 : 0.95),
      side:        THREE.DoubleSide,
      depthWrite:  false,
    };
    if (this.opts.style === 'wireframe') {
      return new THREE.MeshBasicMaterial({ color: colorHex, wireframe: true, transparent: true, opacity: 0.7 });
    }
    if (this.opts.style === 'neon') {
      base.emissiveIntensity = 1.5 * gi;
      base.opacity = 0.9;
    }
    return new THREE.MeshStandardMaterial({ ...base, ...options.extra });
  }

  _wireMat(colorHex, opacity = 0.25) {
    return new THREE.MeshBasicMaterial({
      color: colorHex, wireframe: true,
      transparent: true, opacity,
    });
  }

  // ─── Build Avatar ──────────────────────────────────────────────────────────
  _buildAvatar() {
    const p = this.opts.primaryColor;
    const s = this.opts.secondaryColor;
    const gi = this.opts.glowIntensity;

    this.avatarGroup = new THREE.Group();
    this.avatarGroup.scale.setScalar(this.opts.height);
    this.scene.add(this.avatarGroup);

    // ── HEAD ──────────────────────────────────────────────────────────────────
    this.headGroup = new THREE.Group();
    this.headGroup.position.set(0, 3.15, 0);
    this.avatarGroup.add(this.headGroup);

    // Skull
    const headGeo  = new THREE.SphereGeometry(0.38, 24, 24);
    const headMesh = new THREE.Mesh(headGeo, this._mat(p, { opacity: 0.85 }));
    this.headGroup.add(headMesh);
    // Wireframe overlay
    const headWire = new THREE.Mesh(headGeo, this._wireMat(p, 0.18));
    this.headGroup.add(headWire);
    this.parts.head = headMesh;

    // Face plate (slight flat area for the "face")
    const faceGeo  = new THREE.SphereGeometry(0.36, 16, 16, 0, Math.PI * 2, 0, Math.PI * 0.55);
    const faceMesh = new THREE.Mesh(faceGeo, this._mat(p, { opacity: 0.4, emissive: 0.1 }));
    faceMesh.rotation.x = -0.3;
    faceMesh.position.z = 0.05;
    this.headGroup.add(faceMesh);

    // Eyes
    const eyeGeo = new THREE.SphereGeometry(0.065, 12, 12);
    const eyeMat = new THREE.MeshStandardMaterial({
      color: s, emissive: s, emissiveIntensity: 2.0 * gi,
      transparent: true, opacity: 0.95,
    });
    const eyeL = new THREE.Mesh(eyeGeo, eyeMat);
    const eyeR = new THREE.Mesh(eyeGeo, eyeMat.clone());
    eyeL.position.set(-0.12, 0.04, 0.33);
    eyeR.position.set( 0.12, 0.04, 0.33);
    this.headGroup.add(eyeL, eyeR);
    this.parts.eyeL = eyeL;
    this.parts.eyeR = eyeR;

    // Eye glow lights
    [eyeL, eyeR].forEach(eye => {
      const el = new THREE.PointLight(s, 0.4 * gi, 0.8);
      eye.add(el);
    });

    // Iris rings around eyes
    const irisGeo = new THREE.RingGeometry(0.05, 0.085, 16);
    const irisMat = new THREE.MeshBasicMaterial({ color: s, transparent: true, opacity: 0.7, side: THREE.DoubleSide });
    const irisL = new THREE.Mesh(irisGeo, irisMat);
    const irisR = new THREE.Mesh(irisGeo, irisMat.clone());
    irisL.position.copy(eyeL.position); irisL.position.z += 0.01;
    irisR.position.copy(eyeR.position); irisR.position.z += 0.01;
    this.headGroup.add(irisL, irisR);
    this.parts.irisL = irisL;
    this.parts.irisR = irisR;

    // Mouth indicator
    const mouthGeo = new THREE.TorusGeometry(0.07, 0.012, 8, 16, Math.PI);
    const mouthMat = new THREE.MeshStandardMaterial({
      color: s, emissive: s, emissiveIntensity: 0.8 * gi, transparent: true, opacity: 0.7,
    });
    const mouth = new THREE.Mesh(mouthGeo, mouthMat);
    mouth.position.set(0, -0.12, 0.36);
    mouth.rotation.z = Math.PI;
    this.headGroup.add(mouth);
    this.parts.mouth = mouth;

    // Nose bridge (subtle line)
    const noseGeo = new THREE.CylinderGeometry(0.008, 0.012, 0.1, 8);
    const nose = new THREE.Mesh(noseGeo, this._mat(p, { opacity: 0.5, emissive: 0.3 }));
    nose.position.set(0, -0.02, 0.35);
    nose.rotation.x = 0.3;
    this.headGroup.add(nose);

    // ── HAIR ──────────────────────────────────────────────────────────────────
    this._buildHair();

    // ── NECK ──────────────────────────────────────────────────────────────────
    const neckGeo = new THREE.CylinderGeometry(0.1, 0.12, 0.25, 12);
    const neck = new THREE.Mesh(neckGeo, this._mat(p, { opacity: 0.9 }));
    neck.position.set(0, 2.82, 0);
    this.avatarGroup.add(neck);
    // Neck collar glow ring
    const collarGeo = new THREE.TorusGeometry(0.14, 0.02, 8, 24);
    const collar = new THREE.Mesh(collarGeo, this._mat(s, { emissive: 0.8, opacity: 0.9 }));
    collar.position.set(0, 2.72, 0);
    collar.rotation.x = Math.PI / 2;
    this.avatarGroup.add(collar);

    // ── TORSO ─────────────────────────────────────────────────────────────────
    this.torsoGroup = new THREE.Group();
    this.torsoGroup.position.set(0, 2.2, 0);
    this.avatarGroup.add(this.torsoGroup);

    const torsoGeo = new THREE.CylinderGeometry(0.28, 0.22, 0.85, 16);
    const torso = new THREE.Mesh(torsoGeo, this._mat(p, { opacity: 0.88 }));
    this.torsoGroup.add(torso);
    const torsoWire = new THREE.Mesh(torsoGeo, this._wireMat(p, 0.15));
    this.torsoGroup.add(torsoWire);
    this.parts.torso = torso;

    // Chest circuit lines
    this._buildChestDetails();

    // ── OUTFIT SKIRT / LOWER BODY ─────────────────────────────────────────────
    this._buildOutfit();

    // ── SHOULDERS ─────────────────────────────────────────────────────────────
    const shoulderGeo = new THREE.SphereGeometry(0.14, 12, 12);
    const shoulderMat = this._mat(s, { emissive: 0.6, opacity: 0.9 });
    const shoulderL = new THREE.Mesh(shoulderGeo, shoulderMat);
    const shoulderR = new THREE.Mesh(shoulderGeo, shoulderMat.clone());
    shoulderL.position.set(-0.42, 2.62, 0);
    shoulderR.position.set( 0.42, 2.62, 0);
    this.avatarGroup.add(shoulderL, shoulderR);

    // ── ARMS ──────────────────────────────────────────────────────────────────
    this.armLGroup = new THREE.Group();
    this.armRGroup = new THREE.Group();
    this.armLGroup.position.set(-0.44, 2.45, 0);
    this.armRGroup.position.set( 0.44, 2.45, 0);
    this.avatarGroup.add(this.armLGroup, this.armRGroup);

    const upperArmGeo  = new THREE.CylinderGeometry(0.075, 0.065, 0.5, 10);
    const lowerArmGeo  = new THREE.CylinderGeometry(0.062, 0.055, 0.45, 10);
    const handGeo      = new THREE.SphereGeometry(0.075, 10, 10);

    const armMatL = this._mat(p, { opacity: 0.85 });
    const armMatR = this._mat(p, { opacity: 0.85 });

    // Upper arm L
    const uArmL = new THREE.Mesh(upperArmGeo, armMatL);
    uArmL.position.set(0, -0.25, 0);
    this.armLGroup.add(uArmL);
    // Elbow joint L
    const elbowL = new THREE.Mesh(new THREE.SphereGeometry(0.07, 10, 10), this._mat(s, { emissive: 0.5 }));
    elbowL.position.set(0, -0.5, 0);
    this.armLGroup.add(elbowL);
    // Forearm L
    const fArmLGroup = new THREE.Group();
    fArmLGroup.position.set(0, -0.5, 0);
    const fArmL = new THREE.Mesh(lowerArmGeo, armMatL.clone());
    fArmL.position.set(0, -0.22, 0);
    fArmLGroup.add(fArmL);
    this.armLGroup.add(fArmLGroup);
    // Hand L
    const handL = new THREE.Mesh(handGeo, this._mat(p, { opacity: 0.85 }));
    handL.position.set(0, -0.45, 0);
    fArmLGroup.add(handL);
    this.parts.armLGroup = this.armLGroup;
    this.parts.fArmLGroup = fArmLGroup;

    // Mirror for right arm
    const uArmR = new THREE.Mesh(upperArmGeo, armMatR);
    uArmR.position.set(0, -0.25, 0);
    this.armRGroup.add(uArmR);
    const elbowR = new THREE.Mesh(new THREE.SphereGeometry(0.07, 10, 10), this._mat(s, { emissive: 0.5 }));
    elbowR.position.set(0, -0.5, 0);
    this.armRGroup.add(elbowR);
    const fArmRGroup = new THREE.Group();
    fArmRGroup.position.set(0, -0.5, 0);
    const fArmR = new THREE.Mesh(lowerArmGeo, armMatR.clone());
    fArmR.position.set(0, -0.22, 0);
    fArmRGroup.add(fArmR);
    this.armRGroup.add(fArmRGroup);
    const handR = new THREE.Mesh(handGeo, this._mat(p, { opacity: 0.85 }));
    handR.position.set(0, -0.45, 0);
    fArmRGroup.add(handR);
    this.parts.armRGroup = this.armRGroup;
    this.parts.fArmRGroup = fArmRGroup;

    // Wrist glow rings
    [fArmLGroup, fArmRGroup].forEach(g => {
      const wr = new THREE.Mesh(
        new THREE.TorusGeometry(0.065, 0.012, 8, 20),
        this._mat(s, { emissive: 0.9, opacity: 0.9 })
      );
      wr.position.set(0, -0.38, 0);
      wr.rotation.x = Math.PI / 2;
      g.add(wr);
    });
  }

  _buildHair() {
    const hairColor = this.opts.primaryColor;
    const hairMat = this._mat(hairColor, { emissive: 0.4, opacity: 0.92 });

    this.hairGroup = new THREE.Group();
    this.headGroup.add(this.hairGroup);

    if (this.opts.hairStyle === 'none') return;

    // Top cap
    const topGeo = new THREE.SphereGeometry(0.39, 20, 20, 0, Math.PI * 2, 0, Math.PI * 0.5);
    const top = new THREE.Mesh(topGeo, hairMat);
    top.position.y = 0.06;
    this.hairGroup.add(top);

    if (this.opts.hairStyle === 'long') {
      // Long flowing sections
      const longHairPositions = [-0.18, 0, 0.18];
      longHairPositions.forEach((x, i) => {
        const h = 1.1 + (i % 2) * 0.15;
        const strand = new THREE.Mesh(
          new THREE.CylinderGeometry(0.06 - i * 0.01, 0.01, h, 8),
          hairMat.clone()
        );
        strand.position.set(x * 1.6, -0.8, -0.2);
        strand.rotation.z = x * 0.3;
        strand.rotation.x = 0.15;
        this.hairGroup.add(strand);
      });
      // Side strands
      [-0.38, 0.38].forEach(x => {
        const side = new THREE.Mesh(
          new THREE.CylinderGeometry(0.05, 0.015, 0.8, 8),
          hairMat.clone()
        );
        side.position.set(x, -0.35, 0.1);
        side.rotation.z = x * 0.5;
        this.hairGroup.add(side);
      });
    } else if (this.opts.hairStyle === 'short') {
      const shortGeo = new THREE.SphereGeometry(0.41, 16, 12, 0, Math.PI * 2, 0, Math.PI * 0.65);
      const shortHair = new THREE.Mesh(shortGeo, hairMat);
      shortHair.position.y = 0.02;
      this.hairGroup.add(shortHair);
    } else if (this.opts.hairStyle === 'bun') {
      const bunGeo = new THREE.SphereGeometry(0.16, 14, 14);
      const bun = new THREE.Mesh(bunGeo, hairMat);
      bun.position.set(0, 0.44, -0.15);
      this.hairGroup.add(bun);
      // Bun ring
      const bunRing = new THREE.Mesh(
        new THREE.TorusGeometry(0.14, 0.025, 8, 20),
        this._mat(this.opts.secondaryColor, { emissive: 0.8 })
      );
      bunRing.position.set(0, 0.44, -0.15);
      bunRing.rotation.x = Math.PI / 2;
      this.hairGroup.add(bunRing);
    }
  }

  _buildChestDetails() {
    const s = this.opts.secondaryColor;
    // Circuit-like lines on chest
    const linePositions = [
      [[-0.18, 0.1, 0.27], [-0.06, 0.0, 0.27]],
      [[ 0.06, 0.0, 0.27], [ 0.18, 0.1, 0.27]],
      [[-0.05, -0.1, 0.27], [0.05, -0.1, 0.27]],
    ];
    linePositions.forEach(([a, b]) => {
      const pts = [new THREE.Vector3(...a), new THREE.Vector3(...b)];
      const geo = new THREE.BufferGeometry().setFromPoints(pts);
      const line = new THREE.Line(geo, new THREE.LineBasicMaterial({
        color: s, transparent: true, opacity: 0.7,
      }));
      this.torsoGroup.add(line);
    });

    // Core gem / heart
    const coreGeo = new THREE.OctahedronGeometry(0.07, 0);
    const coreMat = new THREE.MeshStandardMaterial({
      color: s, emissive: s, emissiveIntensity: 2.0 * this.opts.glowIntensity,
      transparent: true, opacity: 0.95,
    });
    const core = new THREE.Mesh(coreGeo, coreMat);
    core.position.set(0, 0.05, 0.26);
    this.torsoGroup.add(core);
    this.parts.core = core;
    const coreLight = new THREE.PointLight(s, 0.8 * this.opts.glowIntensity, 1.2);
    core.add(coreLight);
  }

  _buildOutfit() {
    const p = this.opts.primaryColor;
    const s = this.opts.secondaryColor;

    this.outfitGroup = new THREE.Group();
    this.avatarGroup.add(this.outfitGroup);

    if (this.opts.outfit === 'tactical' || this.opts.outfit === 'armor') {
      // Tactical skirt / lower body
      const skirtGeo = new THREE.CylinderGeometry(0.3, 0.45, 0.7, 16, 1, true);
      const skirt = new THREE.Mesh(skirtGeo, this._mat(p, { opacity: 0.75 }));
      skirt.position.set(0, 1.55, 0);
      this.outfitGroup.add(skirt);

      // Leg panels (tactical)
      if (this.opts.outfit === 'armor') {
        [-0.2, 0.2].forEach(x => {
          const panel = new THREE.Mesh(
            new THREE.BoxGeometry(0.14, 0.3, 0.08),
            this._mat(s, { emissive: 0.4, opacity: 0.9 })
          );
          panel.position.set(x, 1.55, 0.2);
          this.outfitGroup.add(panel);
        });
      }

      // Belt
      const beltGeo = new THREE.CylinderGeometry(0.235, 0.235, 0.06, 20, 1, true);
      const belt = new THREE.Mesh(beltGeo, this._mat(s, { emissive: 0.6, opacity: 0.95 }));
      belt.position.set(0, 1.92, 0);
      this.outfitGroup.add(belt);

      // Legs
      const legGeo = new THREE.CylinderGeometry(0.085, 0.07, 0.9, 12);
      const legMat = this._mat(p, { opacity: 0.9 });
      [-0.16, 0.16].forEach(x => {
        const leg = new THREE.Mesh(legGeo, legMat.clone());
        leg.position.set(x, 0.95, 0);
        this.outfitGroup.add(leg);
        // Knee joint
        const knee = new THREE.Mesh(
          new THREE.SphereGeometry(0.09, 10, 10),
          this._mat(s, { emissive: 0.5 })
        );
        knee.position.set(x, 0.5, 0);
        this.outfitGroup.add(knee);
        // Lower leg
        const lLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.07, 0.065, 0.75, 12), legMat.clone());
        lLeg.position.set(x, 0.1, 0);
        this.outfitGroup.add(lLeg);
        // Ankle ring
        const ankleRing = new THREE.Mesh(
          new THREE.TorusGeometry(0.08, 0.015, 8, 20),
          this._mat(s, { emissive: 0.7, opacity: 0.9 })
        );
        ankleRing.position.set(x, -0.24, 0);
        ankleRing.rotation.x = Math.PI / 2;
        this.outfitGroup.add(ankleRing);
        // Foot
        const foot = new THREE.Mesh(
          new THREE.BoxGeometry(0.14, 0.1, 0.28),
          this._mat(p, { opacity: 0.9 })
        );
        foot.position.set(x, -0.33, 0.04);
        this.outfitGroup.add(foot);
      });

    } else if (this.opts.outfit === 'robe') {
      const robeGeo = new THREE.ConeGeometry(0.55, 1.9, 16, 1, true);
      const robe = new THREE.Mesh(robeGeo, this._mat(p, { opacity: 0.7 }));
      robe.position.set(0, 1.2, 0);
      this.outfitGroup.add(robe);
      const robeWire = new THREE.Mesh(robeGeo, this._wireMat(p, 0.2));
      robeWire.position.copy(robe.position);
      this.outfitGroup.add(robeWire);
    } else {
      // Casual
      const casualGeo = new THREE.CylinderGeometry(0.28, 0.38, 1.4, 16, 1, true);
      const casual = new THREE.Mesh(casualGeo, this._mat(p, { opacity: 0.82 }));
      casual.position.set(0, 1.4, 0);
      this.outfitGroup.add(casual);
    }
  }

  // ─── Environment: floor glow, grid, projection beam ───────────────────────
  _buildEnvironment() {
    // Ground glow disc
    const discGeo = new THREE.CircleGeometry(1.8, 64);
    const discMat = new THREE.MeshBasicMaterial({
      color: this.opts.primaryColor,
      transparent: true, opacity: 0.06,
      side: THREE.DoubleSide,
    });
    const disc = new THREE.Mesh(discGeo, discMat);
    disc.rotation.x = -Math.PI / 2;
    disc.position.y = 0.01;
    this.scene.add(disc);
    this.parts.floorDisc = disc;

    // Outer ring
    const ringGeo = new THREE.RingGeometry(1.5, 1.7, 64);
    const ringMat = new THREE.MeshBasicMaterial({
      color: this.opts.secondaryColor,
      transparent: true, opacity: 0.35,
      side: THREE.DoubleSide,
    });
    const ring = new THREE.Mesh(ringGeo, ringMat);
    ring.rotation.x = -Math.PI / 2;
    ring.position.y = 0.02;
    this.scene.add(ring);
    this.parts.floorRing = ring;

    // Inner ring rotating
    const innerRing = new THREE.Mesh(
      new THREE.RingGeometry(0.9, 1.05, 48),
      new THREE.MeshBasicMaterial({ color: this.opts.primaryColor, transparent: true, opacity: 0.25, side: THREE.DoubleSide })
    );
    innerRing.rotation.x = -Math.PI / 2;
    innerRing.position.y = 0.03;
    this.scene.add(innerRing);
    this.parts.innerRing = innerRing;

    // Ground grid lines
    const gridHelper = new THREE.GridHelper(6, 12, this.opts.primaryColor, this.opts.primaryColor);
    gridHelper.material.transparent = true;
    gridHelper.material.opacity = 0.06;
    this.scene.add(gridHelper);

    // Projection beam (volumetric cone from floor up)
    const beamGeo  = new THREE.CylinderGeometry(0.5, 0.05, 4.5, 32, 1, true);
    const beamMat  = new THREE.MeshBasicMaterial({
      color: this.opts.primaryColor,
      transparent: true, opacity: 0.04,
      side: THREE.DoubleSide,
    });
    const beam = new THREE.Mesh(beamGeo, beamMat);
    beam.position.y = 2.25;
    this.scene.add(beam);
    this.parts.beam = beam;
  }

  // ─── Hologram orbit rings ──────────────────────────────────────────────────
  _buildHologramRings() {
    const configs = [
      { r: 0.65, tube: 0.012, tilt: 0.4,   color: this.opts.secondaryColor, speed: 0.8,  opacity: 0.5 },
      { r: 0.85, tube: 0.010, tilt: -0.6,  color: this.opts.primaryColor,   speed: -0.5, opacity: 0.4 },
      { r: 1.1,  tube: 0.008, tilt: 1.0,   color: this.opts.secondaryColor, speed: 0.3,  opacity: 0.3 },
    ];
    configs.forEach(cfg => {
      const geo = new THREE.TorusGeometry(cfg.r, cfg.tube, 8, 80);
      const mat = new THREE.MeshBasicMaterial({
        color: cfg.color, transparent: true, opacity: cfg.opacity,
      });
      const torus = new THREE.Mesh(geo, mat);
      torus.position.y = 1.8;
      torus.rotation.x = cfg.tilt;
      torus._speed = cfg.speed;
      this.scene.add(torus);
      this.rings.push(torus);
    });
  }

  // ─── Particle system ──────────────────────────────────────────────────────
  _buildParticles() {
    const count = 300;
    const positions = new Float32Array(count * 3);
    const velocities = [];
    for (let i = 0; i < count; i++) {
      const r     = 0.4 + Math.random() * 1.1;
      const theta = Math.random() * Math.PI * 2;
      const phi   = Math.random() * Math.PI;
      positions[i*3]   = r * Math.sin(phi) * Math.cos(theta);
      positions[i*3+1] = 0.3 + Math.random() * 3.2;
      positions[i*3+2] = r * Math.sin(phi) * Math.sin(theta);
      velocities.push({
        vx: (Math.random()-0.5)*0.002,
        vy: (Math.random()-0.5)*0.003 + 0.001,
        vz: (Math.random()-0.5)*0.002,
        origY: positions[i*3+1],
      });
    }
    const geo = new THREE.BufferGeometry();
    geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const mat = new THREE.PointsMaterial({
      color: this.opts.secondaryColor,
      size: 0.022,
      transparent: true,
      opacity: 0.65,
      sizeAttenuation: true,
    });
    this.particles      = new THREE.Points(geo, mat);
    this.particleVels   = velocities;
    this.particlePos    = positions;
    this.scene.add(this.particles);
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

    this._animateBody(t, dt);
    this._animateParticles(t);
    this._animateRings(t);
    this._animateLights(t);
    this._animateEnvironment(t);

    this.renderer.render(this.scene, this.camera);
  }

  _animateBody(t, dt) {
    const moodSpeed = { neutral:1, happy:1.8, curious:1.2, processing:0.8, sad:0.5, excited:2.5 };
    const ms = moodSpeed[this.mood] ?? 1;

    // ── Breathing (torso scale Y) ──────────────────────────────────────────
    if (this.torsoGroup) {
      const breathe = 1 + Math.sin(t * 1.4 * ms) * 0.018;
      this.torsoGroup.scale.y = breathe;
    }

    // ── Head bob + gentle sway ─────────────────────────────────────────────
    if (this.headGroup) {
      this.headGroup.position.y = 3.15 + Math.sin(t * 1.4 * ms) * 0.012;
      this.headGroup.rotation.y = Math.sin(t * 0.4) * 0.1;
      // Curious: head tilt
      if (this.mood === 'curious') {
        this.headGroup.rotation.z = Math.sin(t * 0.6) * 0.12;
      } else {
        this.headGroup.rotation.z *= 0.95;
      }
    }

    // ── Eye pulse ─────────────────────────────────────────────────────────
    if (this.parts.eyeL) {
      const eyePulse = 1 + Math.sin(t * 2.2 * ms) * 0.25;
      const em = 1.8 * this.opts.glowIntensity * eyePulse;
      this.parts.eyeL.material.emissiveIntensity = em;
      this.parts.eyeR.material.emissiveIntensity = em;
    }

    // ── Iris spin ─────────────────────────────────────────────────────────
    if (this.parts.irisL) {
      this.parts.irisL.rotation.z += 0.018 * ms;
      this.parts.irisR.rotation.z -= 0.018 * ms;
    }

    // ── Core gem rotate ───────────────────────────────────────────────────
    if (this.parts.core) {
      this.parts.core.rotation.y += 0.03 * ms;
      this.parts.core.rotation.x += 0.02 * ms;
      const corePulse = 1.5 + Math.sin(t * 3 * ms) * 0.8;
      this.parts.core.material.emissiveIntensity = corePulse * this.opts.glowIntensity;
    }

    // ── Speaking: head nod + mouth open ───────────────────────────────────
    if (this.speaking) {
      if (this.headGroup) {
        this.headGroup.rotation.x = Math.sin(t * 8) * 0.07;
      }
      if (this.parts.mouth) {
        this.parts.mouth.scale.x = 0.7 + Math.abs(Math.sin(t * 9)) * 0.8;
        this.parts.mouth.material.emissiveIntensity = 1.2 + Math.sin(t * 9) * 0.6;
      }
    } else {
      if (this.headGroup) {
        this.headGroup.rotation.x *= 0.9;
      }
      if (this.parts.mouth) {
        this.parts.mouth.scale.x *= 0.95;
        if (this.parts.mouth.scale.x < 1) this.parts.mouth.scale.x = 1;
      }
    }

    // ── Mood: arm poses ───────────────────────────────────────────────────
    if (this.mood === 'happy' || this.mood === 'excited') {
      if (this.parts.armLGroup) {
        this.parts.armLGroup.rotation.z = -0.5 + Math.sin(t * 2 * ms) * 0.15;
        this.parts.armRGroup.rotation.z =  0.5 + Math.sin(t * 2 * ms + 1) * 0.15;
      }
    } else if (this.mood === 'processing') {
      if (this.parts.armLGroup) {
        this.parts.armLGroup.rotation.x = Math.sin(t * 1.5) * 0.1;
        this.parts.armRGroup.rotation.x = Math.cos(t * 1.5) * 0.1;
      }
    } else {
      if (this.parts.armLGroup) {
        // Gentle idle swing
        this.parts.armLGroup.rotation.z = Math.sin(t * 0.9) * 0.08 - 0.06;
        this.parts.armRGroup.rotation.z = -Math.sin(t * 0.9) * 0.08 + 0.06;
        this.parts.armLGroup.rotation.x = Math.sin(t * 0.5) * 0.04;
        this.parts.armRGroup.rotation.x = -Math.sin(t * 0.5) * 0.04;
      }
    }

    // ── Avatar gentle float ────────────────────────────────────────────────
    if (this.avatarGroup) {
      this.avatarGroup.position.y = Math.sin(t * 0.7) * 0.04;
      // Subtle slow Y rotation (looking around)
      this.avatarGroup.rotation.y = Math.sin(t * 0.18) * 0.12;
    }
  }

  _animateParticles(t) {
    if (!this.particles) return;
    const pos = this.particlePos;
    const vel = this.particleVels;
    const count = vel.length;
    const ms = this.mood === 'processing' ? 3 : (this.mood === 'excited' ? 2 : 1);

    for (let i = 0; i < count; i++) {
      pos[i*3]   += vel[i].vx * ms;
      pos[i*3+1] += vel[i].vy * ms;
      pos[i*3+2] += vel[i].vz * ms;
      // Wrap when out of range
      if (pos[i*3+1] > vel[i].origY + 1.5) {
        pos[i*3+1] = vel[i].origY - 0.5;
      }
      const r = Math.sqrt(pos[i*3]*pos[i*3] + pos[i*3+2]*pos[i*3+2]);
      if (r > 1.8 || r < 0.2) {
        vel[i].vx *= -1;
        vel[i].vz *= -1;
      }
    }
    this.particles.geometry.attributes.position.needsUpdate = true;
    this.particles.rotation.y += 0.0015 * ms;
  }

  _animateRings(t) {
    this.rings.forEach(ring => {
      ring.rotation.y += ring._speed * 0.01;
      ring.rotation.z += ring._speed * 0.004;
    });
  }

  _animateLights(t) {
    const gi = this.opts.glowIntensity;
    const ms = this.mood === 'excited' ? 2 : (this.mood === 'processing' ? 1.5 : 1);
    const pulse = Math.sin(t * 1.8 * ms) * 0.5 + 1;
    if (this.purpleLight) {
      this.purpleLight.intensity = 2.5 * gi * pulse;
      this.purpleLight.position.x = Math.sin(t * 0.4) * 0.8;
    }
    if (this.greenLight) {
      this.greenLight.intensity = 1.5 * gi * (1.5 - pulse * 0.5);
      this.greenLight.position.x = Math.cos(t * 0.4) * 0.8;
    }
  }

  _animateEnvironment(t) {
    if (this.parts.innerRing) {
      this.parts.innerRing.rotation.z += 0.012;
    }
    if (this.parts.beam) {
      this.parts.beam.material.opacity = 0.03 + Math.sin(t * 0.8) * 0.01;
    }
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  speak(active = true) {
    this.speaking = active;
    if (active && this.parts.core) {
      this.parts.core.material.emissiveIntensity = 3.0 * this.opts.glowIntensity;
    }
  }

  setMood(mood) {
    this.mood = mood;
    // Color tint based on mood
    const moodColors = {
      neutral:    this.opts.primaryColor,
      happy:      0xFFAA00,
      excited:    0xFF6600,
      curious:    0x00AAFF,
      processing: 0x9D00FF,
      sad:        0x3355AA,
    };
    const c = moodColors[mood] ?? this.opts.primaryColor;
    if (this.purpleLight) this.purpleLight.color.setHex(c);
  }

  customize(opts) {
    // Apply new options and rebuild affected parts
    const rebuild = [];
    if (opts.primaryColor   !== undefined) { this.opts.primaryColor   = opts.primaryColor;   rebuild.push('all'); }
    if (opts.secondaryColor !== undefined) { this.opts.secondaryColor = opts.secondaryColor; rebuild.push('all'); }
    if (opts.glowIntensity  !== undefined) { this.opts.glowIntensity  = opts.glowIntensity; }
    if (opts.hairStyle      !== undefined) { this.opts.hairStyle      = opts.hairStyle;      rebuild.push('hair'); }
    if (opts.outfit         !== undefined) { this.opts.outfit         = opts.outfit;         rebuild.push('outfit'); }
    if (opts.height         !== undefined) { this.opts.height         = opts.height; this.avatarGroup.scale.setScalar(opts.height); }
    if (opts.style          !== undefined) { this.opts.style          = opts.style;          rebuild.push('all'); }
    if (opts.mood           !== undefined) { this.setMood(opts.mood); }

    if (rebuild.includes('all')) {
      this._rebuildAll();
    } else {
      if (rebuild.includes('hair')) this._rebuildHair();
      if (rebuild.includes('outfit')) this._rebuildOutfit();
    }
    // Update lights
    if (this.purpleLight) this.purpleLight.color.setHex(this.opts.primaryColor);
    if (this.greenLight)  this.greenLight.color.setHex(this.opts.secondaryColor);
  }

  _rebuildAll() {
    if (this.avatarGroup) this.scene.remove(this.avatarGroup);
    this._buildAvatar();
  }

  _rebuildHair() {
    if (this.hairGroup) {
      this.hairGroup.children.forEach(c => { if (c.geometry) c.geometry.dispose(); });
      this.hairGroup.clear();
      this._buildHair();
    }
  }

  _rebuildOutfit() {
    if (this.outfitGroup) {
      this.outfitGroup.children.forEach(c => { if (c.geometry) c.geometry.dispose(); });
      this.outfitGroup.clear();
      this._buildOutfit();
    }
  }

  projectLifeSize(active = true) {
    this.projecting = active;
    if (active) {
      // Scale to ~life size (assuming 1 unit ≈ 30cm, so 6 units ≈ 180cm)
      this.avatarGroup.scale.setScalar(this.opts.height * 1.8);
      this.camera.position.set(0, 1.7, 7.5);
      this.camera.lookAt(0, 1.6, 0);
      // Max glow
      const savedGI = this.opts.glowIntensity;
      this.opts.glowIntensity = Math.min(savedGI * 1.5, 3.0);
      if (this.purpleLight) this.purpleLight.intensity = 4.0;
      if (this.parts.beam) this.parts.beam.material.opacity = 0.08;
    } else {
      this.avatarGroup.scale.setScalar(this.opts.height);
      this.camera.position.set(0, 1.6, 4.2);
      this.camera.lookAt(0, 1.4, 0);
      this.opts.glowIntensity = this._savedGI ?? 1.0;
    }
  }

  dispose() {
    this._disposed = true;
    if (this._resizeObs) this._resizeObs.disconnect();
    this.renderer.dispose();
  }
}

// ─── Export globally ──────────────────────────────────────────────────────────
window.AriaAvatar3D = AriaAvatar3D;
