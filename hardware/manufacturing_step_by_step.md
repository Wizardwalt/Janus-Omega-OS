# Janus Titan Omega - Master Manufacturing & Packaging Guide

## Phase 1: Electronics Manufacturing (PCB & SMT)
**Who to Contact**: [JLCPCB](https://jlcpcb.com) or [PCBWay](https://pcbway.com).
**Files to Send**:
- `hardware/pcb/schematic_master.md` (Reference for their engineers)
- **Gerber Files** (Generated from CAD - includes board layout)
- **BOM (Bill of Materials)**: `hardware/production_bom.md`
- **CPL (Component Placement List)**: Pick-and-place coordinates.
**Action**: Request "PCB Fabrication + SMT Assembly" service. They will source the components and deliver the fully populated boards.

## Phase 2: Housing Fabrication (CNC & 3D Printing)
**Who to Contact**: [Xometry](https://xometry.com) or [Protolabs](https://protolabs.com).
**Files to Send**:
- `hardware/housing/housing_guide.md` (Material and finishing specs)
- **STEP/STL Files** (3D models for the 10-inch chassis and analog knobs)
- **DXF Files** (For the CNC-machined 6061 aluminum faceplate)
**Action**: Order SLS 3D Printing in PA12-CF for the main body and CNC Machining for the faceplate.

## Phase 3: Battery & Accessory Production
**Who to Contact**: [Xometry](https://xometry.com) (for Stand/Dock) and [18650BatteryStore](https://18650batterystore.com) (for bulk cells).
**Files to Send**:
- `hardware/housing/monolith_forge.md` (Design for Stand and Dock)
- `hardware/battery/battery_spec.md` (Magazine specifications)
**Action**: Order the machined aluminum bases for the Monolith and the custom pogo-pin connectors for the Mjolnir magazines.

## Phase 4: Final Assembly & Packaging
**Who to Contact**: A local Contract Manufacturer (CM) or a specialized fulfillment house like [ShipBob](https://shipbob.com).
**Files to Send**:
- `hardware/production_bom.md` (Assembly Guide section)
- **JanusOS ISO Image** (The final software build)
- **Packaging Artwork** (Branding and box designs)
**Action**: 
1. The CM assembles the electronics into the housings.
2. Performs IP68 vacuum pressure testing.
3. Flashes the JanusOS software to the internal NVMe storage.
4. Packages the unit with the Monolith stand, 2x Mjolnir magazines, and a ruggedized USB-C cable.

## Phase 5: Delivery
**Action**: Units are ready to ship to customers via the fulfillment partner.
