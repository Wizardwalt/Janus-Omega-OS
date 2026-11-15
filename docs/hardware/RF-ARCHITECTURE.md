# Janus RF Architecture — Titan and Monolith

## Product requirement

Janus uses a two-tier RF architecture:

1. **Pandora Titan / Pip-Boy:** the compact, self-contained wearable smartphone and field computer. Its chassis carries the broadest practical integrated antenna and radio set that can be engineered into the small form factor.
2. **Janus Monolith:** the larger companion dock/base station. It carries a more capable, physically larger antenna system and higher-performance radio front ends, while also providing the same supported radio families present in the Pip-Boy. When docked or linked, it supplements and extends the Pip-Boy rather than replacing its onboard radios.

The Pip-Boy remains independently useful when away from the Monolith. The Monolith is an expansion/base-station platform, not merely a passive charging stand.

## Radio-family coverage to engineer

The hardware team must maintain a verified radio/antenna matrix covering, as applicable to the selected modules and legal operating region:

- Cellular modem bands and MIMO paths (voice/data modem and GNSS coexistence requirements).
- Wi-Fi bands and MIMO paths, plus Bluetooth.
- GNSS positioning and timing.
- NFC and HF proximity interfaces.
- UWB ranging and ranging-antenna layout.
- Sub-GHz transceiver bands supported by the selected chipset and region.
- Wideband receive / SDR coverage using suitable external or integrated front ends.
- Optional specialist radio modules and external antenna ports where board area, thermal limits, filtering, isolation, and regulatory approvals permit.

This is a coverage requirement, not a claim that one antenna can efficiently cover every band. Each radio path needs an antenna or antenna system designed for its frequency range, impedance, bandwidth, efficiency, polarization, isolation, and enclosure environment. Transmit-capable radios must use supported, certified configurations and respect regional spectrum rules. Receive-only SDR paths must be explicitly distinguished from transmit-capable radios.

## Monolith expansion

The Monolith should include:

- Larger, higher-efficiency antenna elements and/or external antenna connectors for supported bands.
- More capable RF front ends where justified: low-noise amplification, filtering, switching, duplexing, and band-specific transceivers.
- Shared radio families matching the Pip-Boy, with a capability matrix that states whether each feature is local, dock-assisted, or unavailable.
- Wired high-speed data and power connection to the Pip-Boy, plus secure control/data interfaces.
- Thermal management, RF shielding/grounding, and isolation between simultaneous radios.
- A dock-aware radio manager that can select the best available local or Monolith path without silently changing transmit behavior.

The Monolith's exact antenna count, bands, gain, connector types, power levels, and simultaneous-radio combinations remain engineering decisions until the RF inventory and mechanical layout are finalized. Do not invent these values in marketing or software capability reports.

## Coexistence and validation

The compact wearable enclosure creates severe antenna compromises. The design must validate:

- Antenna efficiency and tuning in the final chassis, with the device worn on a human arm.
- SAR / RF exposure, EMC, carrier certification, and regional regulatory compliance.
- Desense, intermodulation, harmonics, receiver blocking, and coexistence among cellular, Wi-Fi, Bluetooth, GNSS, SDR, sub-GHz, NFC, and UWB systems.
- Simultaneous-radio operation, switching behavior, thermal rise, battery draw, and real-world range.
- Performance both undocked and docked, with the Monolith attached over the intended wired/wireless interface.

Antenna placement and tuning must be based on measured prototypes, not a simple antenna-count target. The final design should maximize useful, independently validated coverage while preserving safe RF exposure and reliable everyday cellular service.

## Current repository documentation gaps

The existing hardware notes identify a subset of the intended radios (cellular, Wi-Fi/Bluetooth, Sub-GHz, NFC, SDR, and UWB), but they do not yet contain a complete band-by-band antenna schedule or a Monolith RF/base-station design. The current Monolith document describes charging and USB-C data passthrough only. Those documents must be reconciled with this two-tier product requirement before the hardware can be considered manufacturing-ready.

The current hardware files also contain conflicting platform details (for example, memory and display dimensions across the hardware specification, BOM, PCB specification, and manufacturing guide). Treat those values as draft until a single controlled system specification resolves them.

## Required next engineering artifacts

1. Controlled radio inventory: radio/module part number, supported bands, transmit/receive status, interface, supply, peak current, thermal load, regulatory status, and firmware/driver.
2. Antenna schedule: one row per RF path with frequency range, antenna technology, placement, feed, matching network, connector, isolation target, and measured efficiency.
3. Monolith RF block diagram and BOM, including its antenna system and wired link to Titan.
4. Coexistence matrix for simultaneous radio combinations.
5. Mechanical CAD/EM simulation and prototype test plan, followed by conducted and over-the-air measurements.
6. Updated product support matrix distinguishing Titan-only, Monolith-assisted, accessory-dependent, and future/planned capabilities.
