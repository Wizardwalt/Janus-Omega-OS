# Dual-Boot Installation & Setup Guide

This guide explains how to set up and use the dual-boot system on the Pandora Titan, allowing seamless switching between JanusOS and Android.

## Overview

The Pandora Titan's dual-boot system uses:
- **NVMe Slot 1**: JanusOS (primary OS)
- **NVMe Slot 2**: Android (smartphone OS)
- **Boot Selection**: Tactical button press at startup

## Hardware Requirements

- Pandora Titan with dual NVMe M.2 slots
- 2x NVMe SSD drives (512GB+ recommended)
- MicroSD card for shared storage (optional)
- USB-C cable for initial setup

## Pre-Installation Setup

### 1. Prepare NVMe Drives

Insert NVMe drives into both M.2 slots:
- **Slot 1 (closest to USB)**: JanusOS drive
- **Slot 2**: Android drive

Verify detection:
```bash
# Boot to recovery mode first
lsblk  # Should show /dev/nvme0n1 and /dev/nvme1n1
```

### 2. Create Partitions

For **NVMe Slot 1 (JanusOS)**:
```bash
# Create partitions
parted /dev/nvme0n1 mklabel gpt
parted /dev/nvme0n1 mkpart primary fat32 1MiB 501MiB      # /boot
parted /dev/nvme0n1 mkpart primary ext4 501MiB 250GiB     # /
parted /dev/nvme0n1 mkpart primary ext4 250GiB -1         # /home

# Format
mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3
```

For **NVMe Slot 2 (Android)**:
```bash
# Create partitions
parted /dev/nvme1n1 mklabel gpt
parted /dev/nvme1n1 mkpart primary fat32 1MiB 501MiB      # /boot
parted /dev/nvme1n1 mkpart primary ext4 501MiB 250GiB     # /
parted /dev/nvme1n1 mkpart primary ext4 250GiB -1         # /data

# Format
mkfs.fat -F 32 /dev/nvme1n1p1
mkfs.ext4 /dev/nvme1n1p2
mkfs.ext4 /dev/nvme1n1p3
```

## Installing JanusOS

### 1. Download JanusOS Image

```bash
# Assuming image file is janusos-titan.img
wget https://github.com/Wizardwalt/Janus-Omega-OS/releases/download/latest/janusos-titan.img
```

### 2. Write to NVMe Slot 1

```bash
# Mount partitions
mkdir -p /mnt/boot /mnt/root /mnt/home
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/nvme0n1p2 /mnt/root
mount /dev/nvme0n1p3 /mnt/home

# Extract JanusOS
tar -xzf janusos-titan.img -C /mnt/

# Copy kernel and initrd to boot
cp /mnt/boot/vmlinuz* /dev/nvme0n1p1/
cp /mnt/boot/initrd* /dev/nvme0n1p1/

# Verify
ls -la /mnt/boot/
```

## Installing Android

### 1. Download Android Image

For Pandora Titan, use LineageOS or similar ARM distribution:

```bash
# Example: LineageOS for ARM64
wget https://example.com/lineageos-arm64-titan.zip
unzip lineageos-arm64-titan.zip
```

### 2. Write to NVMe Slot 2

```bash
# Mount partitions
mkdir -p /mnt/android_boot /mnt/android_root /mnt/android_data
mount /dev/nvme1n1p1 /mnt/android_boot
mount /dev/nvme1n1p2 /mnt/android_root
mount /dev/nvme1n1p3 /mnt/android_data

# Extract Android
tar -xzf lineageos-arm64-titan.img -C /mnt/android_root/

# Copy kernel
cp /mnt/android_root/boot/vmlinuz* /mnt/android_boot/
cp /mnt/android_root/boot/initrd* /mnt/android_boot/
```

## Installing Bootloader

### 1. Copy Bootloader Script

```bash
# Mount internal NAND or recovery partition
mkdir -p /mnt/recovery
mount /dev/mtd0 /mnt/recovery

# Copy bootloader
cp system/dual_boot/bootloader.lua /mnt/recovery/bootloader.lua

# Verify
ls -la /mnt/recovery/bootloader.lua
```

### 2. Configure Bootloader

Create `/boot/bootloader.conf`:

```ini
# Default boot OS (1 = JanusOS, 2 = Android)
DEFAULT_OS=1

# Boot timeout in seconds
BOOT_TIMEOUT=10

# Enable safe boot
SAFE_BOOT=1

# Boot slot (0 = NVMe0, 1 = NVMe1)
JANUSOS_SLOT=0
ANDROID_SLOT=1
```

### 3. Test Bootloader

```bash
# Load bootloader into RAM
kexec -l /boot/bootloader.lua

# Execute bootloader (will show boot menu)
kexec -e
```

## First Boot

### 1. Power On Titan

- Press brass toggle on Titan
- Wait for bootloader to initialize (~3 seconds)
- Bootloader menu appears on display

### 2. Boot Menu Options

```
PANDORA TITAN - DUAL BOOT MENU
================================
[1] Boot JanusOS (Offensive Security)
[2] Boot Android (Smartphone Mode)
[3] Recovery/Maintenance Mode
[R] Reboot
[S] System Information
```

### 3. Select Boot Option

For **first boot**, select option `[1]` to boot JanusOS:

```
Press: 1
Boot: Loading JanusOS from /dev/nvme0n1...
```

JanusOS will load in ~4-10 seconds.

## Configuration After Boot

### On JanusOS

1. **Network Setup**
   ```bash
   nmtui  # Network manager
   ```

2. **Install Phone Capabilities**
   ```bash
   cp plugins/phone_capabilities/*.lua ~/.janus/modules/
   ```

3. **Configure Cellular**
   ```bash
   # Check modem
   lsusb | grep Quectel
   
   # Insert SIM card into Nano-SIM slot
   mmcli -m 0 --sim-status
   ```

4. **Set Default OS** (optional)
   ```lua
   -- Edit /boot/bootloader.conf
   DEFAULT_OS=1  -- Set JanusOS as default
   ```

### On Android

1. **Initial Setup**
   - Complete Android setup wizard
   - Connect to Wi-Fi

2. **Install Phone Capabilities** (Android native)
   - Android includes native Phone app
   - SMS via Android Messaging
   - Browser via Chrome
   - Email via Gmail app

3. **Configure Cellular**
   - Settings → Network → Mobile Network
   - Insert SIM card details
   - Enable 5G/LTE

## Switching Between OS

### Method 1: At Boot Time

1. Power off Titan (or hold power 10 seconds)
2. Wait for bootloader screen
3. Press `[1]` for JanusOS or `[2]` for Android
4. System boots selected OS

### Method 2: Soft Reboot (JanusOS)

From JanusOS terminal:

```lua
-- Reboot to Android
os.execute("reboot 2")

-- Reboot to JanusOS
os.execute("reboot 1")
```

### Method 3: Boot Menu (during JanusOS/Android)

Press: **Tactical Button + Power** (hold 3 seconds)
- Brings up boot menu
- Select new OS
- System reboots to selection

## Troubleshooting

### Bootloader Won't Start

**Problem**: Black screen after pressing power button

**Solution**:
```bash
# Enter recovery mode: Hold Tactical Button + press Power
# From recovery shell:
fsck /dev/nvme0n1p1
fsck /dev/nvme0n1p2
kexec -l /boot/bootloader.lua
kexec -e
```

### JanusOS Won't Boot

**Problem**: "No bootable partition found"

**Solution**:
```bash
# Use recovery mode to check partitions
parted /dev/nvme0n1 print
mount /dev/nvme0n1p2 /mnt
ls -la /mnt/boot/
```

### Android Won't Boot

**Problem**: Stuck on Android logo

**Solution**:
1. Boot to recovery (press Tactical Button at Android startup)
2. From recovery: `wipe cache partition`
3. Reboot

### Modem Not Detected

**Problem**: "Quectel RM520N-GL not found"

**Solution**:
```bash
# Check USB device
lsusb
# Should show: Bus 001 Device XXX: ID 2c7c:0125 Quectel Wireless

# Reload driver
modprobe -r qcserial
modprobe qcserial
```

### Can't Switch Between OS

**Problem**: Tactical button not working

**Solution**:
```bash
# Check GPIO input
cat /sys/class/gpio/gpio23/value
# Should toggle between 0 and 1 when button pressed

# If not working, manually reboot:
reboot 2  # Reboot to Android
reboot 1  # Reboot to JanusOS
```

## Performance Optimization

### Speed Up JanusOS Boot

Edit `/boot/bootloader.conf`:
```ini
SKIP_FSCK=1        # Skip filesystem check
SKIP_MEMORY_TEST=1 # Skip memory test
```

### Speed Up Android Boot

In Android Settings:
- Developer Options → Disable USB debugging until needed
- Settings → Storage → Cache → Clear

## Backup & Recovery

### Backup JanusOS

```bash
# From JanusOS
tar -czf janusos-backup.tar.gz /

# From Android/Recovery
dd if=/dev/nvme0n1 of=/mnt/backup/janusos-full.img bs=1M status=progress
```

### Backup Android

```bash
# From recovery mode
adb backup -apk -shared -all -f android-backup.adb

# Or clone NVMe Slot 2
dd if=/dev/nvme1n1 of=/mnt/backup/android-full.img bs=1M
```

### Restore from Backup

```bash
# Restore JanusOS
mount /dev/nvme0n1p2 /mnt
tar -xzf janusos-backup.tar.gz -C /mnt

# Restore Android
dd if=android-full.img of=/dev/nvme1n1 bs=1M status=progress
sync
```

## Advanced Configuration

### Create Custom Boot Splash

```bash
# Create custom image (1440x576 resolution)
convert -size 1440x576 xc:black custom_splash.png
# Convert to framebuffer format
ffmpeg -i custom_splash.png -f rawvideo -pix_fmt rgb24 splash.raw

# Copy to bootloader
cp splash.raw /boot/splash.raw
```

### Add Third Boot Option

Edit `bootloader.lua`:
```lua
-- Add new boot mode
BOOT_MODES.CUSTOMOS = 4

function bootloader.boot_custom()
    -- Your custom OS boot code
end
```

### Encrypted Partitions

For added security, encrypt NVMe partitions:

```bash
# Create encrypted container
cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup luksOpen /dev/nvme0n1p3 janusos_home
mkfs.ext4 /dev/mapper/janusos_home
```

## Next Steps

1. **On JanusOS**: Follow [Phone Capabilities Guide](phone_capabilities.md)
2. **On Android**: Use standard smartphone apps
3. **File Sharing**: Use MicroSD card or network for data transfer

---

**Guide Version**: 1.0  
**Last Updated**: 2026-04-30  
**Hardware**: Pandora Titan (dual NVMe slots)
