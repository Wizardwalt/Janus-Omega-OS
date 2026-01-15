# Pandora Titan Master Schematic

## 1. Power Distribution (Schematic Block)
[BATT_PACK (2S2P)] --(Pogo-Pins)--> [BMS_CORE]
[KINETIC_HARVESTER] --(Rectifier)--> [BMS_CORE]
[BMS_CORE] --(100W PD)--> [SYSTEM_RAILS (12V, 5V, 3.3V, 1.8V)]
[WIRELESS_RX_COIL] --(Qi_Controller)--> [BMS_CORE]

## 2. Processing & Logic
[RADXA_CM5_SOM] <--(PCIe)--> [RP2040_MCU]
[RADXA_CM5] --(MIPI_DSI)--> [5" DISPLAY]
[RP2040] --(I2C/SPI)--> [HYDRA_RADIO_ARRAY]
[RP2040] --(GPIO)--> [CHORDED_KEYS/ENCODERS]

## 3. Hydra Radio Array
[CC1101] --(RF_SWITCH)--> [SUB-GHZ_ANTENNA]
[PN532] --(MATCHING_NET)--> [NFC_PCB_ANTENNA]
[RTL-SDR_IC] --(LNA)--> [VHF/UHF_ANTENNA]
[DWM3000] <--(SPI)--> [UWB_ANTENNA]

## 4. Sensory & CBRN
[FLIR_LEPTON] --(VoSPI)--> [RADXA_CM5]
[BME680] --(I2C)--> [RP2040] (CBRN Detection)
[MLX90614] --(I2C)--> [RP2040] (IR Temp)
