# VL68 Pro (UNISOC) — Network SIM Lock Unlock Procedure

**Status:** User-tested and verified on one VL68 Pro  
**Evidence level:** Confirmed by the device owner; not independently reproduced  
**Scope:** Network Lock only. Do not assume this applies to other lock categories or other UNISOC devices.

## Summary

The device owner reports successfully removing the carrier Network Lock on a VL68 Pro by opening the built-in UNISOC SIMLOCK settings activity through Shizuku and Activity Manager. The phone restarted automatically after the Network Lock was changed to **Unlock**. A SIM from a different carrier was then inserted and successfully used for an ordinary phone call.

This is a documented device-specific procedure, not a guaranteed universal UNISOC unlock method.

## Requirements

- VL68 Pro with the relevant UNISOC phone software present.
- Shizuku configured and running.
- Activity Manager installed and able to launch the relevant activity.
- The built-in package/activity entry exposed as `com.unisoc.phone` → **SIMLOCK Setting**.

## Procedure reported by the device owner

1. Start Shizuku.
2. Open Activity Manager.
3. Locate `com.unisoc.phone`.
4. Launch **SIMLOCK Setting**.
5. The SIMLOCK screen presents five categories:
   - Network Lock
   - NetworkSubset Lock
   - ServiceProvider Lock
   - Corporate Lock
   - SIM Lock
6. Open **Network Lock**.
7. The interface offers the appropriate **Lock** or **Unlock** action according to the current state.
8. Choose **Unlock** for Network Lock only if this is the lock that is active and you are authorized to unlock the device.
9. On the tested VL68 Pro, the phone restarted automatically after the action.
10. Verify with a SIM from another carrier and confirm ordinary calling works.

## Important observations

- On the reported device, only **Network Lock** was locked and needed to be changed.
- NetworkSubset Lock, ServiceProvider Lock, Corporate Lock, and SIM Lock were already unlocked.
- The owner reports that each category exposes a corresponding Lock/Unlock action depending on its current state. The other categories were not changed or tested as part of the successful network-unlock operation.
- A successful cross-carrier ordinary phone call was reported after the automatic restart.

## Safety and limitations

- This procedure has been verified by the owner on one VL68 Pro only. Other firmware versions, regional variants, carriers, and UNISOC devices may behave differently or may not expose this activity.
- Do not change the other SIMLOCK categories merely because they are present. They are separate personalization controls and were not needed for the reported network unlock.
- Do not experiment with unknown engineering settings, modem/NV data, or unrelated lock categories.
- Make sure you own the device or have the owner's/carrier's authorization before changing its lock state.
- If the interface does not clearly show the current state or offers an unexpected action, stop rather than guessing.
- This procedure does not establish that bootloader unlocking, FRP removal, or any other device restriction is affected.

## Verification status

| Check | Reported result |
|---|---|
| SIMLOCK Setting opened through Shizuku + Activity Manager | Yes |
| Network Lock changed to Unlock | Yes |
| Automatic restart after unlock | Yes |
| Other four categories changed | No; they were already unlocked |
| Different-carrier SIM tested | Yes |
| Ordinary phone call completed | Yes |

## Aria / Janus capability-catalog entry

**Capability name:** UNISOC SIMLOCK Settings — VL68 Pro Network Lock workflow  
**Category:** Mobile device servicing / carrier-lock diagnostics  
**Support status:** Device-specific field procedure; owner-verified on one VL68 Pro  
**Invocation:** Guided/manual workflow only; no automated lock-state changes  
**Required operator approval:** Explicit confirmation before selecting Unlock  
**Safety boundary:** Never alter unrelated lock categories; never claim support for another model without independent validation.

Aria should present this as a documented, device-specific procedure and explain its evidence level and limitations. Aria must not silently invoke the activity or change a lock state on the user's behalf.
