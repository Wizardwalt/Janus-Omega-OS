# Phone Capabilities Guide - Pandora Titan

This guide explains how to use the phone capabilities built into JanusOS on the Pandora Titan.

## Overview

JanusOS now includes **5 complete phone modules** that integrate with the Titan's Quectel RM520N-GL 5G/LTE modem:

1. **Phone Dialer** - Voice calling
2. **SMS Messenger** - Text messaging
3. **Internet Browser** - Web browsing
4. **Email Client** - Email management
5. **Voice Assistant** - Voice commands

All modules are written in **Lua** and deeply integrated with the Titan's hardware.

## Prerequisites

- Pandora Titan with dual NVMe drives
- Valid cellular SIM card (Nano-SIM slot on Titan)
- Internet connection (Wi-Fi or cellular)
- JanusOS running on NVMe Slot 0

## Phone Dialer Module

### Starting Phone Dialer

```lua
-- From Janus TUI
Phone Capabilities → Phone Dialer
-- Or from command line
janus phone_dialer
```

### Making Calls

**Dial a number:**
```lua
phone_dialer.dial("+1-555-1234")
-- or without formatting
phone_dialer.dial("5551234")
```

**Call a saved contact:**
```lua
phone_dialer.dial_contact("Mom")
```

**Display all contacts:**
```lua
phone_dialer.show_contacts()
```

**Add a new contact:**
```lua
phone_dialer.save_contact("Friend", "+1-555-5678")
```

### Receiving Calls

When a call comes in:
```lua
phone_dialer.accept_call()    -- Answer call
phone_dialer.reject_call()    -- Reject call
phone_dialer.end_call()       -- Hang up
```

### Call Management

**Check signal strength:**
```lua
phone_dialer.get_signal_strength()
-- Output: SIGNAL: 4/5 bars (-75 dBm)
```

**Check network status:**
```lua
phone_dialer.get_network_status()
-- Output: NETWORK: Registered, home
```

**View call history:**
```lua
phone_dialer.show_history()
```

**During a call:**
```lua
phone_dialer.mute()            -- Mute microphone
phone_dialer.unmute()          -- Unmute microphone
phone_dialer.enable_speaker()  -- Enable speakerphone
phone_dialer.disable_speaker() -- Disable speakerphone
```

## SMS Messenger Module

### Starting SMS Messenger

```lua
-- From Janus TUI
Phone Capabilities → SMS Messenger
-- Or from command line
janus sms_messenger
```

### Sending Messages

**Send SMS to a number:**
```lua
sms_messenger.send_sms("+1-555-1234", "Hello World!")
```

**Send to a contact:**
```lua
sms_messenger.send_to_contact("Mom", "Hey, I'll be late")
```

**Create and save a draft:**
```lua
sms_messenger.create_draft("+1-555-5678", "Your message here")
```

**Send a draft:**
```lua
sms_messenger.show_drafts()
sms_messenger.send_draft(1)  -- Send first draft
```

### Receiving Messages

New SMS messages are automatically logged. Check unread count:
```lua
sms_messenger.get_unread_count()
-- Output: UNREAD MESSAGES: 3
```

### Message Management

**View message threads:**
```lua
sms_messenger.show_threads()
-- Shows all conversations grouped by contact
```

**Get thread with specific contact:**
```lua
local thread = sms_messenger.get_thread("+1-555-1234")
```

**Mark message as read:**
```lua
sms_messenger.mark_as_read(1)
```

**Delete message:**
```lua
sms_messenger.delete_message(1)
```

**Search messages:**
```lua
local results = sms_messenger.search("meeting")
```

**Export messages:**
```lua
sms_messenger.export_messages("messages_backup.txt")
-- Saves to ~/.janus/messages_backup.txt
```

## Internet Browser Module

### Starting Browser

```lua
-- From Janus TUI
Phone Capabilities → Internet Browser
-- Or from command line
janus internet_browser
```

### Basic Navigation

**Visit a website:**
```lua
internet_browser.navigate("github.com")
-- Automatically adds https:// if not present
```

**Search Google:**
```lua
internet_browser.search("Pandora Titan specifications")
```

**Go to bookmark:**
```lua
internet_browser.goto_bookmark("GitHub")
```

### Bookmarks

**Show all bookmarks:**
```lua
internet_browser.show_bookmarks()
```

**Add a bookmark:**
```lua
internet_browser.add_bookmark("MyBlog", "https://example.com")
```

### History & Cache

**View browsing history:**
```lua
internet_browser.show_history()
-- Shows last 20 pages visited
```

**Go back:**
```lua
internet_browser.go_back()
```

**Clear history:**
```lua
internet_browser.clear_history()
```

**Clear cache:**
```lua
internet_browser.clear_cache()
```

### Downloads

**Download a file:**
```lua
internet_browser.download("https://example.com/file.zip", "myfile.zip")
-- Saves to ~/Downloads/myfile.zip
```

## Email Client Module

### Starting Email

```lua
-- From Janus TUI
Phone Capabilities → Email Client
-- Or from command line
janus email_client
```

### Account Management

**Show all accounts:**
```lua
email_client.show_accounts()
```

**Select an account:**
```lua
email_client.set_account("Gmail")
```

**Add new account:**
```lua
email_client.add_account("Work", "user@company.com", "password", "gmail")
```

Supported providers: `gmail`, `outlook`, `yahoo`, `custom`

### Sending Email

**Send email:**
```lua
email_client.send_email("recipient@example.com", "Subject", "Email body text")
```

**Create draft:**
```lua
email_client.create_draft("recipient@example.com", "Subject", "Email body")
```

### Checking Mail

**Check for new emails:**
```lua
email_client.check_mail()
```

**View inbox:**
```lua
email_client.show_inbox()
```

**View sent folder:**
```lua
email_client.show_sent()
```

**View drafts:**
```lua
email_client.show_drafts()
```

### Email Management

**Search emails:**
```lua
local results = email_client.search("important")
```

**Delete email:**
```lua
email_client.delete_email("inbox", 1)
```

**Export to MBOX format:**
```lua
email_client.export_mbox("inbox", "my_inbox")
-- Saves to ~/my_inbox.mbox
```

## Voice Assistant Module

### Activating Voice Assistant

```lua
-- From Janus TUI
Phone Capabilities → Voice Assistant
-- Or from command line
janus voice_assistant
```

### Voice Commands

**Wake word:** Say "Janus" to activate

**Phone commands:**
- "dial [number]" → Make a call
- "text [contact]" → Send a text message
- "call [contact]" → Call a saved contact

**Browser commands:**
- "search [query]" → Google search
- "open [website]" → Navigate to website
- "go back" → Return to previous page

**System commands:**
- "volume [0-100]" → Adjust volume
- "screenshot" → Take screenshot
- "lock" → Lock device
- "help" → Show help

**General commands:**
- "status" → Check device status
- "time" → Get current time
- "date" → Get current date
- "weather" → Get weather report

### Dictation

**Start dictation:**
```lua
voice_assistant.dictation_mode()
```

Say your message and it will be transcribed for SMS or email.

### Custom Commands

**Register custom command:**
```lua
voice_assistant.register_command("meeting", "calendar_open")
```

## Troubleshooting

### Cellular Modem Not Detected

**Problem:** "Cellular modem not detected"

**Solution:**
1. Check SIM card is inserted in Nano-SIM slot
2. Verify modem is detected:
   ```bash
   lsusb | grep -i quectel
   ```
3. Reload modem driver:
   ```bash
   modprobe -r qcserial
   modprobe qcserial
   ```

### Can't Make Calls

**Problem:** "Dialing failed" or call drops

**Solution:**
1. Check signal strength: `phone_dialer.get_signal_strength()`
2. Check network status: `phone_dialer.get_network_status()`
3. Verify SIM card is active
4. Try at a different location

### SMS Not Sending

**Problem:** "SMS failed to send"

**Solution:**
1. Check you have an active plan with SMS
2. Verify number format (include country code)
3. Check network connection
4. Try with shorter message

### No Internet Connection

**Problem:** "Failed to load page"

**Solution:**
1. Enable Wi-Fi: `nmcli radio wifi on`
2. Or use cellular: Check signal strength
3. Verify DNS is working:
   ```bash
   nslookup google.com
   ```

### Email Not Checking

**Problem:** "Mail check failed"

**Solution:**
1. Verify internet connection (Wi-Fi or cellular)
2. Check account credentials are correct
3. Verify IMAP/SMTP ports are correct
4. Try manually selecting account: `email_client.set_account("Gmail")`

## Advanced Usage

### Automate Phone Tasks

Create a Lua script to automate phone tasks:

```lua
-- Auto-dial support if urgent
if janus.is_emergency() then
    phone_dialer.dial_contact("Emergency")
end

-- Check mail every hour
if janus.time_since_last_check() > 3600 then
    email_client.check_mail()
end

-- Send daily backup text
if janus.is_daily_time("09:00") then
    sms_messenger.send_to_contact("Backup", "Daily backup complete")
end
```

### Voice-to-SMS Pipeline

```lua
-- Use voice assistant to compose and send SMS
voice_assistant.listen_and_execute()
-- User says: "text Mom I'll be home soon"
-- Module parses and sends: sms_messenger.send_to_contact("Mom", "I'll be home soon")
```

### Auto-Reply

```lua
-- Enable auto-reply when in a meeting
sms_messenger.create_auto_reply("In a meeting. I'll respond shortly.")

-- Disable after meeting
sms_messenger.disable_auto_reply()
```

## Performance Tips

1. **Reduce data usage**: Disable auto-mail checking on cellular
2. **Extend battery**: Use minimal speaker volume
3. **Faster browsing**: Clear cache regularly
4. **Save messages**: Export important conversations monthly

## Security Considerations

1. **Never save passwords** in plain text
2. **Use VPN** for email on public Wi-Fi
3. **Encrypt sensitive emails** if possible
4. **Lock device** when not in use
5. **Review contacts** and delete unused ones

## Next Steps

- Explore dual-boot system: See `dual_boot_installation.md`
- Integrate with JanusOS modules for advanced workflows
- Build custom phone extensions in Lua

---

**Guide Version**: 1.0  
**Last Updated**: 2026-04-30  
**Module Count**: 5 (Phone + SMS + Browser + Email + Voice)
