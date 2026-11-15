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

## Current Titan / Monolith capability matrix

This table separates **intended placement** from **current availability**. It is not a claim that either device exists or that any radio is operational. The repository contains no completed Titan or Monolith prototype, selected and reconciled RF BOM, production radio drivers, or measured RF validation.

| Radio family | Titan while undocked | Monolith while docked | Current Janus status |
|---|---|---|---|
| Cellular modem (voice, SMS, mobile data) | **Intended onboard** modem; Titan must retain normal phone service independently | **Planned dock-assisted matching modem family** and compatible external antenna/front-end options; Titan retains its own modem | **Unavailable / unverified.** A Quectel RM520N-GL is named in the draft PCB notes, but there is no production cellular adapter or carrier/SIM certification evidence. RCS depends on the Android/carrier stack, not an SDR. |
| Wi-Fi and Bluetooth | **Intended onboard** combo radio | **Planned dock-assisted matching radio family** with larger antenna/front-end options | **Unavailable / unverified.** The PCB notes name an Intel AX210, while the Lua hardware manifest names other parts; no Janus radio adapter or coexistence test is present. |
| GNSS | **Intended onboard** receiver and antenna | **Planned dock-assisted matching receiver family** with larger antenna/front-end options | **Unavailable / unverified.** A u-blox M10 appears in a Lua manifest, but no reconciled BOM, production driver, or location validation is present. |
| NFC / HF | **Intended onboard** reader and tuned antenna | **Planned dock-assisted matching reader family** and optional larger antenna | **Unavailable / unverified.** PN532 is a draft candidate only; no working Janus adapter is present. |
| UWB | **Intended onboard** ranging radio and antenna | **Planned dock-assisted matching ranging family** and optional improved antenna layout | **Unavailable / unverified.** Draft files conflict between DWM3000 and DW3110; no selected part or ranging validation exists. |
| Sub-GHz transceiver | **Intended onboard** region-appropriate TX/RX module, subject to legal band and power limits | **Planned dock-assisted matching transceiver family** with improved filtering/front ends and external antenna options | **Unavailable / unverified.** CC1101 is a draft candidate; there is no production RF adapter, antenna schedule, or conducted/OTA test. |
| SDR — receive-only | **Candidate onboard** RTL-SDR-class receiver | **Planned dock-assisted matching receive-only family** with higher-performance front ends and external antennas | **Unavailable / unverified.** RTL-SDR appears in draft BOM/schematic notes, but no receiver driver or hardware validation is present. Receive-only hardware does not provide transmit capability. |
| SDR — transmit-capable | **Not assigned; unavailable** until a specific TX-capable radio chain is selected and validated | **Not assigned; unavailable** until a separate TX-capable front end, filtering, isolation, controls, and compliance work are completed | **Unavailable.** Do not infer transmit support from the RTL-SDR candidate or from unverified Lua marketing claims. |
| Specialist / satellite radios | **Unavailable until a specific supported module is selected** | **Potential matching dock/accessory expansion**, not yet designed | **Unavailable / planned only.** No verified parts, drivers, spectrum authorization, or service path are recorded. |
| External antenna ports | Internal antennas only after the Titan RF layout is finalized | **Intended Monolith option** for selected supported bands | **Unavailable / unverified.** Connector types, feeds, switching, isolation, and enclosure layout are not specified. |

**Status legend:** *Intended onboard* means the product design calls for the function to live on Titan; *planned dock-assisted* means Monolith may add that radio family through the secure dock/link; *unavailable* means software and UI must not expose it as a working feature today. All entries above remain planned or unverified until the selected parts, drivers, prototype measurements, and applicable approvals exist.

The current janus-runtime hardware layer reports GPIO, cellular, RF, and sensor adapters as unsupported. Its cellular and RF scan methods return empty lists; sensor reads return fixed placeholder values; and the serial open/read/write methods are placeholders. The Monolith housing document currently describes a stand/charging dock with Qi charging and USB-C data passthrough, not an implemented Monolith radio base station.

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
