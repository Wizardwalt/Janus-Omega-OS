# Janus Mobile Troubleshooting & Setup Guide

## 1. ADB CONNECTION ISSUES
- **Check Driver Status**: Run `adb devices` in the terminal. If the device says `unauthorized`, check the phone screen for the RSA key prompt.
- **Service Restart**: If the phone is not detected, use the **Hardware** tab in Janus Omega or run:
  ```bash
  adb kill-server && adb start-server
  ```
- **Cable Integrity**: Ensure you are using a high-quality data cable (Pandora Mk.1 recommended for glitching operations).

## 2. IOS (LIBIMOBILEDEVICE) ISSUES
- **Trust Request**: iOS devices must be unlocked and "Trust this Computer" must be selected.
- **Pairing**: Run `idevicepair pair` to force a new pairing record.
- **Extraction**: Use `ideviceinfo` to verify the device is communicating with the Janus core.

## 3. LUA MODULE ERRORS (getprop N/A)
- **Root Status**: Many mobile modules require root access. Ensure the target is rooted or use `dragnet.lua` to attempt an escalation.
- **Shell Errors**: If you see `ERR: command not found`, ensure `android-tools` are installed on the host. (The system has been updated to provide better error reporting in the logs).
