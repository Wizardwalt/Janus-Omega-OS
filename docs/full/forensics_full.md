# Forensics — Full Module Reference
**Category:** `forensics` | **Total Modules:** 152 | *Every module individually documented*

---

## data_carver — WAL & SQLite Journal Carver

**Platform:** android

**What it does:** Scans for SQLite WAL (Write-Ahead Log) and journal files on the target device. Reconstructs deleted records from SMS, call logs, and any app database that uses SQLite — even after the app has been uninstalled.

**How to run:**
1. Connect device (ADB/libimobiledevice)
2. Forensics → data_carver
3. Select scope: All DBs / SMS / Calls / App-specific
4. Wait for scan — results saved to /Evidence/carved/

**Expected output:**
```
SCANNING FOR SQLITE JOURNALS...
FOUND: 14 WAL FILES
RECOVERING DELETED SMS/CALLS...
RECONSTRUCTED: 89 DELETED RECORDS
SAVED: /Evidence/carved/wal_results.json
```

**Note:** Works even when app data has been 'deleted' — WAL files persist until the database is checkpointed.

---

## for_001 — Full Disk Image Acquisition

**Platform:** android

**What it does:** Creates a full byte-for-byte image of the device's internal storage. The image is hash-verified (SHA-256 and MD5) and stored in raw or E01 format for forensic chain-of-custody.

**How to run:**
1. Ensure device is rooted
2. Forensics → for_001
3. Select output format: RAW / E01
4. Confirm target partition: /data, /sdcard, or Full
5. Monitor progress — typically 15-45 min for 64GB

**Expected output:**
```
FULL DISK ACQUISITION: STARTING
TARGET: /dev/block/sda
SIZE: 64.0 GB
FORMAT: E01
PROGRESS: [=========>  ] 87%
SHA-256: [computed]
COMPLETE: /Evidence/images/device_full.E01
```

**Note:** Always run this first — it preserves the complete device state before any other module modifies data.

---

## for_002 — Logical File System Extraction

**Platform:** android/ios

**What it does:** Extracts all user-accessible files and folders from the device's logical file system without requiring a full image. Faster than for_001 but does not capture deleted data.

**How to run:**
1. Forensics → for_002
2. Select extraction scope: Full / User data only / App data only
3. Choose compression: None / ZIP / TAR.GZ
4. Extraction runs via ADB pull or AFC protocol (iOS)

**Expected output:**
```
LOGICAL EXTRACTION: STARTING
FILES FOUND: 24,891
EXTRACTING...
PROGRESS: [=====>      ] 52%
COMPLETE: /Evidence/logical_extract/
```

**Note:** Use this for quick triage when time is limited. Follow up with for_001 for complete forensic acquisition.

---

## for_003 — SQLite Database Inventory

**Platform:** android/ios

**What it does:** Locates and catalogues every SQLite database file on the device, including hidden and app-private databases. Returns a full list with file paths, sizes, and table counts.

**How to run:**
1. Forensics → for_003
2. Select scan scope: All / User apps / System / Custom path
3. Review inventory in log pane
4. Export list to Evidence folder

**Expected output:**
```
SQLITE INVENTORY SCAN: RUNNING
SCAN PATH: /data/data/
DATABASES FOUND: 347
TOTAL SIZE: 2.1 GB
LARGEST: com.whatsapp/databases/msgstore.db (890MB)
INVENTORY: /Evidence/db_inventory.json
```

**Note:** Review the inventory before running targeted extraction — large databases take longer to process.

---

## for_004 — WAL Journal Recovery

**Platform:** android/ios

**What it does:** Specifically targets Write-Ahead Log (.wal) and shared memory (.shm) files across all SQLite databases. Reconstructs deleted rows that haven't been checkpointed yet.

**How to run:**
1. Forensics → for_004
2. Optionally filter by app package name
3. Module scans all .wal and .shm files
4. Recovered rows exported as JSON

**Expected output:**
```
WAL JOURNAL RECOVERY: RUNNING
WAL FILES FOUND: 23
PROCESSING: msgstore.db-wal [847 pages]
RECOVERED ROWS: 1,243
SAVED: /Evidence/wal_recovered.json
```

**Note:** Most effective immediately after device seizure — WAL files are overwritten during normal device use.

---

## for_005 — SMS Database Extraction

**Platform:** android

**What it does:** Extracts the complete SMS/MMS database (mmssms.db) including all threads, messages, attachments, and metadata. Includes delivery receipts and read timestamps.

**How to run:**
1. Forensics → for_005
2. Select output format: JSON / CSV / HTML timeline
3. Option: include MMS attachments (recommended)
4. Extraction completes in 1-5 minutes

**Expected output:**
```
SMS EXTRACTION: RUNNING
MESSAGES FOUND: 14,892
THREADS: 234
MMS ATTACHMENTS: 1,204
SAVED: /Evidence/sms/sms_full.json
HTML TIMELINE: /Evidence/sms/timeline.html
```

**Note:** Also checks for third-party SMS apps (Google Messages, Samsung Messages, Textra) — extracts from all.

---

## for_006 — Call Log Database Extraction

**Platform:** android/ios

**What it does:** Extracts the complete call history including incoming, outgoing, and missed calls with timestamps, duration, and contact associations. Includes VoIP app call logs.

**How to run:**
1. Forensics → for_006
2. Select scope: Native calls / VoIP apps / Both
3. Output: JSON / CSV / Timeline
4. Exports to /Evidence/calls/

**Expected output:**
```
CALL LOG EXTRACTION: RUNNING
NATIVE CALLS: 4,231
WHATSAPP CALLS: 892
SIGNAL CALLS: 134
FACETIME (iOS): 445
TOTAL: 5,702 RECORDS
SAVED: /Evidence/calls/call_log_full.json
```

**Note:** Cross-references contacts database to resolve phone numbers to names automatically.

---

## for_007 — Contacts Database Dump

**Platform:** android/ios

**What it does:** Dumps the complete contacts database including all fields: name, phone numbers, emails, addresses, notes, photos, and relationship metadata. Handles multiple accounts (Google, Samsung, iCloud).

**How to run:**
1. Forensics → for_007
2. Select accounts to include: All / Specific account
3. Include contact photos: Yes / No
4. Output: VCF / JSON / CSV

**Expected output:**
```
CONTACTS DUMP: RUNNING
ACCOUNTS: Google (1), Samsung (1)
CONTACTS FOUND: 1,204
PHOTOS: 892
SAVED: /Evidence/contacts/contacts_full.vcf
SAVED: /Evidence/contacts/contacts_full.json
```

**Note:** Deleted contacts may be recovered via WAL analysis — run for_004 first for best results.

---

## for_008 — WhatsApp Message Recovery

**Platform:** android

**What it does:** Extracts the complete WhatsApp message database (msgstore.db) including text messages, media metadata, call logs, group chats, and status updates. Attempts to recover deleted messages via WAL.

**How to run:**
1. Forensics → for_008
2. Device must be rooted for full private data access
3. Module copies and decrypts msgstore.db
4. Exports all chats as JSON and HTML timeline

**Expected output:**
```
WHATSAPP EXTRACTION: RUNNING
MESSAGES: 45,231
MEDIA FILES: 8,904
GROUP CHATS: 47
DELETED (RECOVERED): 1,204
SAVED: /Evidence/whatsapp/wa_full.json
HTML: /Evidence/whatsapp/chats.html
```

**Note:** WhatsApp encrypts its backup — this module handles decryption automatically using the key from the secure storage.

---

## for_009 — Telegram Cache Extraction

**Platform:** android/ios

**What it does:** Extracts Telegram's local message cache, session data, and cached media. Telegram stores significant message history locally even for self-destruct messages.

**How to run:**
1. Forensics → for_009
2. Select extraction depth: Cache only / Full local DB
3. Attempts decryption using extracted session key
4. Exports messages and media

**Expected output:**
```
TELEGRAM EXTRACTION: RUNNING
CACHED MESSAGES: 12,445
MEDIA CACHED: 2,341 FILES
SESSION KEY: EXTRACTED
DECRYPTION: COMPLETE
SAVED: /Evidence/telegram/
```

**Note:** Self-destruct messages may still be in cache if the timer hasn't fired — check timestamps carefully.

---

## for_010 — Signal App Forensics

**Platform:** android/ios

**What it does:** Attempts to extract Signal's encrypted message database. Signal uses SQLCipher — this module extracts the encryption key from the keystore/keychain and decrypts the database.

**How to run:**
1. Forensics → for_010
2. Requires root (Android) or jailbreak (iOS)
3. Module extracts SQLCipher key from secure storage
4. Decrypts and exports message database

**Expected output:**
```
SIGNAL FORENSICS: RUNNING
SQLCIPHER KEY: EXTRACTED FROM KEYSTORE
DATABASE SIZE: 445 MB
DECRYPTING...
MESSAGES RECOVERED: 8,921
SAVED: /Evidence/signal/signal_messages.json
```

**Note:** Signal aggressively clears memory — run immediately after device seizure for best key recovery rate.

---

## for_011 — Instagram Data Extraction

**Platform:** android/ios

**What it does:** Extracts Instagram's local database including DMs, following/followers lists, cached photos and stories, search history, and activity log.

**How to run:**
1. Forensics → for_011
2. Extracts from app private storage (requires root/jailbreak)
3. Also downloads public profile data via API if credentials found
4. Media cached locally is extracted to Evidence

**Expected output:**
```
INSTAGRAM EXTRACTION: RUNNING
DIRECT MESSAGES: 3,441
FOLLOWERS: 892 | FOLLOWING: 445
CACHED PHOTOS: 1,204
SEARCH HISTORY: 234 QUERIES
SAVED: /Evidence/instagram/
```

**Note:** Combine with OSINT Oracle → osint_011 for full social media cross-reference.

---

## for_012 — Facebook Messenger Forensics

**Platform:** android/ios

**What it does:** Extracts Facebook Messenger local database including conversations, media, group chats, call logs, and reaction history.

**How to run:**
1. Forensics → for_012
2. Root/jailbreak required for private data
3. Extracts both personal and group thread data
4. Media file metadata included

**Expected output:**
```
MESSENGER EXTRACTION: RUNNING
CONVERSATIONS: 178
MESSAGES: 24,891
GROUP CHATS: 23
MEDIA FILES: 4,451
SAVED: /Evidence/messenger/
```

**Note:** Facebook may also be extracted via for_011 runner — both share some database tables on Android.

---

## for_013 — Snapchat Cache Recovery

**Platform:** android/ios

**What it does:** Recovers Snapchat cached snaps and conversation data. Snapchat deletes content after viewing but residual data often persists in cache directories.

**How to run:**
1. Forensics → for_013
2. Scans /data/data/com.snapchat.android/ and cache dirs
3. Reconstructs viewable images from cached segments
4. Exports recovered snaps and conversation list

**Expected output:**
```
SNAPCHAT RECOVERY: RUNNING
CACHE DIRS SCANNED: 8
SNAP FRAGMENTS FOUND: 445
RECONSTRUCTED: 312 SNAPS
CONVERSATIONS: 34
SAVED: /Evidence/snapchat/
```

**Note:** Success rate varies by device/version — newer versions fragment and encrypt aggressively.

---

## for_014 — TikTok Data Forensics

**Platform:** android/ios

**What it does:** Extracts TikTok's local data including draft videos, DMs, search history, viewed video metadata, and account identifiers.

**How to run:**
1. Forensics → for_014
2. Extracts from app private storage
3. Identifies linked phone number and email
4. Exports activity and communication data

**Expected output:**
```
TIKTOK EXTRACTION: RUNNING
ACCOUNT: [IDENTIFIED]
DRAFT VIDEOS: 12
DIRECT MESSAGES: 891
SEARCH HISTORY: 1,204
SAVED: /Evidence/tiktok/
```

**Note:** TikTok stores extensive device telemetry locally — useful for identifying linked accounts.

---

## for_015 — Email App Forensics

**Platform:** android/ios

**What it does:** Extracts email from Gmail, Outlook, Samsung Email, Apple Mail, and other email clients. Captures message bodies, attachments, sent items, drafts, and full headers.

**How to run:**
1. Forensics → for_015
2. Select email apps to target: All / Specific
3. Date range filter available
4. Exports .eml files and JSON index

**Expected output:**
```
EMAIL EXTRACTION: RUNNING
GMAIL: 12,445 MESSAGES
OUTLOOK: 3,221 MESSAGES
ATTACHMENTS: 891 FILES
DRAFTS: 45
SAVED: /Evidence/email/
```

**Note:** Drafts and deleted items (from trash) are also captured — often contain sensitive unsent content.

---

## for_016 — Chrome Browser History

**Platform:** android/ios

**What it does:** Extracts full Chrome browser history including URLs, visit timestamps, page titles, typed URLs, downloaded files, and saved passwords from the History and Login Data databases.

**How to run:**
1. Forensics → for_016
2. Root required for private storage access
3. Extracts History, Login Data, Cookies, and Downloads
4. Timeline view generated automatically

**Expected output:**
```
CHROME FORENSICS: RUNNING
HISTORY ENTRIES: 45,892
DOWNLOADS: 234
SAVED PASSWORDS: 67
COOKIES: 1,204
SAVED: /Evidence/browsers/chrome/
```

**Note:** Chrome sync history may be available via for_033 (Cloud Sync) if Google account credentials are found.

---

## for_017 — Firefox/Gecko Browser Forensics

**Platform:** android

**What it does:** Extracts Firefox for Android history, bookmarks, saved logins, cookies, and form data from the places.sqlite and key4.db databases.

**How to run:**
1. Forensics → for_017
2. Targets Firefox and Firefox Focus databases
3. Decrypts saved logins using key4.db
4. Exports complete browsing profile

**Expected output:**
```
FIREFOX FORENSICS: RUNNING
HISTORY: 12,445 ENTRIES
BOOKMARKS: 234
LOGINS: 45 (DECRYPTED)
COOKIES: 891
SAVED: /Evidence/browsers/firefox/
```

**Note:** Firefox Focus purges history on close — run immediately if device was recently seized.

---

## for_018 — Browser Cookies Extraction

**Platform:** android/ios

**What it does:** Extracts authentication cookies from all installed browsers. Valid session cookies can be used to access accounts without credentials.

**How to run:**
1. Forensics → for_018
2. Scans all installed browsers
3. Exports raw cookie data and identifies active sessions
4. Flags high-value cookies (banking, email, social media)

**Expected output:**
```
COOKIE EXTRACTION: RUNNING
BROWSERS SCANNED: 4
COOKIES FOUND: 8,445
ACTIVE SESSIONS: 23
HIGH-VALUE: 8 (Google, Facebook, Bank)
SAVED: /Evidence/browsers/cookies.json
```

**Note:** Active cookies expire — use immediately if you need account access.

---

## for_019 — Browser Download History

**Platform:** android/ios

**What it does:** Extracts the complete download history from all browsers including file names, source URLs, download timestamps, and local save paths. Recovers metadata even for deleted files.

**How to run:**
1. Forensics → for_019
2. Scans all browser download databases
3. Cross-references with file system for actual files
4. Reports deleted downloads with original URLs

**Expected output:**
```
DOWNLOAD HISTORY: RUNNING
DOWNLOADS FOUND: 1,204
FILES PRESENT: 891
FILES DELETED (METADATA ONLY): 313
SAVED: /Evidence/browsers/downloads.json
```

**Note:** Original download URLs are preserved — useful for tracking where files came from.

---

## for_020 — Browser Search History

**Platform:** android/ios

**What it does:** Extracts search queries from all browsers, search engine apps, and voice assistant logs. Captures search terms, timestamps, and which search engine was used.

**How to run:**
1. Forensics → for_020
2. Scans browsers + Google app + Siri/Bixby logs
3. Groups by date and topic cluster (AI-assisted)
4. Timeline view generated

**Expected output:**
```
SEARCH HISTORY: RUNNING
SEARCHES FOUND: 34,891
SOURCES: Chrome, Google App, Bixby
TOP TOPICS (AI): [classified]
SAVED: /Evidence/browsers/search_history.json
```

**Note:** Google app search history syncs to cloud — cross-reference with for_033 for cloud-side data.

---

## for_021 — GPS Location History (Native)

**Platform:** android/ios

**What it does:** Extracts GPS location history from the device's native location database, including timestamps, accuracy, altitude, and speed data.

**How to run:**
1. Forensics → for_021
2. Select time range: All / Last 30 days / Custom
3. Exports as JSON + KML for map visualization
4. Movement pattern analysis optional (AI-assisted)

**Expected output:**
```
GPS EXTRACTION: RUNNING
LOCATION POINTS: 234,891
DATE RANGE: [first] to [last]
ACCURACY: Avg 4.2m
SAVED: /Evidence/location/gps_history.json
SAVED: /Evidence/location/gps_history.kml
```

**Note:** KML file can be opened in Google Earth for full movement visualization.

---

## for_022 — Google Maps Timeline

**Platform:** android

**What it does:** Extracts Google Maps Timeline data from the local database — includes visited places, routes traveled, and place inferences (home, work, gym, etc.).

**How to run:**
1. Forensics → for_022
2. Requires Google Maps app data access (root)
3. Extracts timeline.db and inferred places
4. Exports timeline with place names resolved

**Expected output:**
```
GOOGLE MAPS TIMELINE: RUNNING
LOCATIONS: 12,445
PLACES INFERRED: 234
HOME LOCATION: [IDENTIFIED]
WORK LOCATION: [IDENTIFIED]
SAVED: /Evidence/location/maps_timeline.json
```

**Note:** Google Timeline data is extremely granular — often reveals daily routines and frequented locations.

---

## for_023 — Ride & Delivery App History

**Platform:** android/ios

**What it does:** Extracts trip and order history from Uber, Lyft, DoorDash, Instacart, and similar apps — including pickup/dropoff addresses, timestamps, and payment method metadata.

**How to run:**
1. Forensics → for_023
2. Select apps: All / Specific
3. Extracts from local database and cached API responses
4. Maps pickup/dropoff points to KML

**Expected output:**
```
RIDE APP EXTRACTION: RUNNING
UBER TRIPS: 445
LYFT TRIPS: 123
DOORDASH ORDERS: 892
ADDRESSES EXTRACTED: 1,204
SAVED: /Evidence/location/ride_history.json
```

**Note:** Delivery addresses are high-value intelligence — often reveal home, work, and social visit locations.

---

## for_024 — EXIF Data Extractor

**Platform:** android/ios

**What it does:** Extracts and parses EXIF metadata from all photos and videos on the device. GPS coordinates, device model, timestamp, and camera settings are extracted and cross-referenced.

**How to run:**
1. Forensics → for_024
2. Scans DCIM, Downloads, and all accessible media paths
3. Extracts GPS from every photo with location data
4. Generates KML map of photo locations

**Expected output:**
```
EXIF EXTRACTION: RUNNING
PHOTOS SCANNED: 8,445
WITH GPS: 3,221
WITHOUT GPS: 5,224
DATE RANGE: [first] to [last]
SAVED: /Evidence/exif/exif_data.json
SAVED: /Evidence/exif/photo_locations.kml
```

**Note:** Photos shared on social media often strip EXIF — this captures from the device originals before stripping.

---

## for_025 — Photo & Video Timestamp Forensics

**Platform:** android/ios

**What it does:** Analyzes file system timestamps, EXIF timestamps, and camera metadata to build an accurate chronological timeline of all media captured on the device. Detects timestamp manipulation.

**How to run:**
1. Forensics → for_025
2. Select media scope: Photos only / Video only / Both
3. Anomaly detection: flag files where metadata timestamps don't match filesystem timestamps
4. Timeline report generated

**Expected output:**
```
TIMESTAMP FORENSICS: RUNNING
MEDIA FILES: 9,892
TIMESTAMP ANOMALIES: 12 FILES
  -> 3 files: EXIF modified after capture
  -> 9 files: Filesystem time earlier than EXIF
SAVED: /Evidence/media/timestamp_report.json
```

**Note:** Timestamp anomalies often indicate file manipulation — document these carefully.

---

## for_026 — App Installation Timeline

**Platform:** android

**What it does:** Reconstructs when every app was installed, updated, and uninstalled using the package manager database and system logs.

**How to run:**
1. Forensics → for_026
2. Includes current apps and uninstall history
3. Correlates install times with location data
4. Exports chronological timeline

**Expected output:**
```
APP INSTALL TIMELINE: RUNNING
CURRENT APPS: 127
UNINSTALLED (RECOVERED): 45
TIMELINE BUILT: 2021-01 to [current]
SAVED: /Evidence/apps/install_timeline.json
```

**Note:** Uninstalled app history is often overlooked — may reveal apps deleted to hide activity.

---

## for_027 — App Usage Statistics

**Platform:** android

**What it does:** Extracts the Android UsageStats database showing exactly how long each app was used each day, which apps were in foreground, and precise usage timestamps.

**How to run:**
1. Forensics → for_027
2. Select time range: All / Last 90 days / Custom
3. Exports per-app daily usage breakdown
4. Generates visual usage chart

**Expected output:**
```
APP USAGE STATS: RUNNING
APPS WITH DATA: 89
HIGHEST USAGE: [App] - 4.2 hrs/day avg
DATA RANGE: [first] to [current]
SAVED: /Evidence/apps/usage_stats.json
```

**Note:** Usage statistics persist for 2 weeks by default — older data may be unavailable.

---

## for_028 — Screen Time Data

**Platform:** ios

**What it does:** Extracts iOS Screen Time database (RMAdminStore) including app usage, pickups, notifications, and Screen Time password if set.

**How to run:**
1. Forensics → for_028
2. iOS device with jailbreak or backup access
3. Extracts knowledgeC.db (Screen Time source)
4. Decrypts Screen Time passcode if set

**Expected output:**
```
SCREEN TIME EXTRACTION: RUNNING
APP USAGE DATA: 90 DAYS
PICKUPS: 45,892
NOTIFICATIONS RECEIVED: 123,445
SCREEN TIME PASSCODE: [if found]
SAVED: /Evidence/apps/screen_time.json
```

**Note:** knowledgeC.db is one of the richest forensic sources on iOS — contains app, location, and device state data.

---

## for_029 — Notification History

**Platform:** android

**What it does:** Extracts notification history from Android's notification database — shows all received notifications with app, title, text, timestamp, and whether they were dismissed or tapped.

**How to run:**
1. Forensics → for_029
2. Requires root for notification database access
3. Recovers dismissed notifications up to history limit
4. Exports full notification log

**Expected output:**
```
NOTIFICATION HISTORY: RUNNING
NOTIFICATIONS: 234,891
APPS: 67
OLDEST RECORD: [date]
SAVED: /Evidence/system/notification_history.json
```

**Note:** Notification content often includes message previews — useful for reading message content without full database access.

---

## for_030 — Clipboard History

**Platform:** android

**What it does:** Extracts clipboard history contents. Some launchers and keyboard apps maintain clipboard history — this module checks all common sources.

**How to run:**
1. Forensics → for_030
2. Checks: Gboard clipboard, Samsung clipboard, custom launchers
3. Also checks current clipboard content
4. Exports all clipboard items with timestamps

**Expected output:**
```
CLIPBOARD EXTRACTION: RUNNING
GBOARD HISTORY: 45 ITEMS
SAMSUNG CLIPBOARD: 23 ITEMS
CURRENT CLIPBOARD: [content]
SAVED: /Evidence/system/clipboard.json
```

**Note:** Clipboard often contains copied passwords, account numbers, and sensitive text — high value target.

---

## for_031 — Deleted File Recovery (FAT/EXT4)

**Platform:** android

**What it does:** Performs undelete operations on FAT32 and EXT4 file systems. Scans for file signatures (magic bytes) to recover deleted photos, videos, documents, and other files.

**How to run:**
1. Forensics → for_031
2. Requires full disk access (root)
3. Select target partition: /sdcard (FAT32) / /data (EXT4)
4. Carves files by signature — JPEG, MP4, PDF, DOCX, ZIP

**Expected output:**
```
DELETED FILE RECOVERY: RUNNING
PARTITION: /sdcard (FAT32)
SCANNING: 64.0 GB
SIGNATURES FOUND: 892
RECOVERED FILES: 678 (JPG: 445, MP4: 123, PDF: 67, OTHER: 43)
SAVED: /Evidence/recovered/
```

**Note:** Recovery rate depends on how much data has been written since deletion — run as early as possible.

---

## for_032 — SD Card Forensics

**Platform:** android

**What it does:** Complete forensic acquisition and analysis of an inserted SD card — creates image, recovers deleted files, and extracts file system metadata.

**How to run:**
1. Forensics → for_032
2. SD card must be inserted in target or Pandora
3. Creates raw image of SD card
4. Runs file signature carving on unallocated space

**Expected output:**
```
SD CARD FORENSICS: RUNNING
CARD SIZE: 256 GB
FORMAT: FAT32
ALLOCATED FILES: 45,891
UNALLOCATED SPACE: 45 GB
FILES RECOVERED: 1,204
SAVED: /Evidence/sdcard/
```

**Note:** SD cards are rarely encrypted — often contain older photos and files that were 'moved' from internal storage.

---

## for_033 — Cloud Sync History (Google)

**Platform:** android

**What it does:** Extracts Google Drive sync history, recently modified cloud files, and backup metadata from the device's local Google sync database.

**How to run:**
1. Forensics → for_033
2. Google account must be logged in on device
3. Extracts sync database from Google Play Services
4. Lists cloud files with local sync status

**Expected output:**
```
GOOGLE DRIVE SYNC: RUNNING
ACCOUNT: [identified]
SYNCED FILES: 8,445
RECENTLY MODIFIED: 234
BACKUP CONTENTS: [listed]
SAVED: /Evidence/cloud/google_sync.json
```

**Note:** For cloud-side data, use Cloud Dumper (core_omega → 60_cloud_dumper) with extracted credentials.

---

## for_034 — Cloud Sync History (iCloud)

**Platform:** ios

**What it does:** Extracts iCloud sync history, local iCloud Drive contents, and backup metadata from iOS device.

**How to run:**
1. Forensics → for_034
2. iOS device with jailbreak or physical access
3. Extracts CloudDocs and iCloud Drive local cache
4. Identifies linked iCloud account

**Expected output:**
```
ICLOUD SYNC: RUNNING
ACCOUNT: [identified]
LOCAL CLOUD FILES: 3,221
LAST BACKUP: [timestamp]
BACKUP INCLUDES: Photos, Messages, Keychain
SAVED: /Evidence/cloud/icloud_sync.json
```

**Note:** iCloud backup contents can be enumerated without downloading — use account credentials for full access.

---

## for_035 — Dropbox Activity Log

**Platform:** android/ios

**What it does:** Extracts Dropbox local database, cached files, activity log, and linked device information.

**How to run:**
1. Forensics → for_035
2. Requires Dropbox app installed and root access
3. Extracts local Dropbox database
4. Lists all shared folders and recent file activity

**Expected output:**
```
DROPBOX EXTRACTION: RUNNING
ACCOUNT: [identified]
LOCAL FILES: 1,204
SHARED FOLDERS: 12
RECENT ACTIVITY: 445 EVENTS
SAVED: /Evidence/cloud/dropbox.json
```

**Note:** Dropbox stores file thumbnails locally — even deleted remote files may have local thumbnail artifacts.

---

## for_036 — Banking App Data

**Platform:** android/ios

**What it does:** Extracts locally cached data from banking apps including account numbers, transaction history, and stored credentials. Lists all detected banking apps.

**How to run:**
1. Forensics → for_036
2. Scans for all recognized banking app packages
3. Extracts unencrypted or decryptable cached data
4. Transaction history compiled to report

**Expected output:**
```
BANKING APP FORENSICS: RUNNING
BANKING APPS FOUND: 3
CACHED TRANSACTIONS: 892
ACCOUNT INFO: [partial numbers]
CREDENTIALS: [if stored insecurely]
SAVED: /Evidence/financial/banking.json
```

**Note:** Many banking apps use certificate pinning and app-level encryption — results vary by app and version.

---

## for_037 — Cryptocurrency Wallet Data

**Platform:** android/ios

**What it does:** Extracts crypto wallet app data including wallet addresses, transaction history, and attempts to recover seed phrases from insecure storage.

**How to run:**
1. Forensics → for_037
2. Detects all installed crypto wallet apps
3. Extracts wallet addresses and transaction cache
4. Scans for seed phrases in plain storage

**Expected output:**
```
CRYPTO WALLET FORENSICS: RUNNING
WALLETS FOUND: MetaMask, Trust Wallet
ADDRESSES: [listed]
TRANSACTIONS: 234
SEED PHRASE CHECK: NOT FOUND IN PLAIN STORAGE
SAVED: /Evidence/financial/crypto.json
```

**Note:** Combine with core_omega → 56_wallet_recovery for deeper seed phrase extraction attempts.

---

## for_038 — Payment App History (Venmo/PayPal/CashApp)

**Platform:** android/ios

**What it does:** Extracts payment transaction history from Venmo, PayPal, CashApp, Zelle, and similar apps.

**How to run:**
1. Forensics → for_038
2. Scans for all payment app packages
3. Extracts transaction history from local database
4. Includes recipient names, amounts, memos

**Expected output:**
```
PAYMENT APP FORENSICS: RUNNING
APPS FOUND: Venmo, PayPal, CashApp
TRANSACTIONS: 892
CONTACTS IN TRANSACTIONS: 67
SAVED: /Evidence/financial/payments.json
```

**Note:** Venmo transactions are public by default — cross-reference with OSINT Oracle for additional intelligence.

---

## for_039 — Stock & Trading App Forensics

**Platform:** android/ios

**What it does:** Extracts trading history, portfolio data, and watchlists from Robinhood, E*TRADE, TD Ameritrade, Coinbase, and similar apps.

**How to run:**
1. Forensics → for_039
2. Scans for trading app packages
3. Extracts cached portfolio and trade history
4. Exports holdings and transaction records

**Expected output:**
```
TRADING APP FORENSICS: RUNNING
APPS FOUND: Robinhood, Coinbase
TRADES: 234
HOLDINGS: [listed]
ACCOUNT VALUE (CACHED): [amount]
SAVED: /Evidence/financial/trading.json
```

**Note:** Cached portfolio data may be hours old — note the last sync timestamp in report.

---

## for_040 — Health & Fitness Data

**Platform:** android/ios

**What it does:** Extracts health and fitness data from Google Fit, Apple Health, Samsung Health, Fitbit, and wearable sync data.

**How to run:**
1. Forensics → for_040
2. Scans all health platform databases
3. Extracts steps, heart rate, sleep, workouts, weight
4. Timeline built from combined sources

**Expected output:**
```
HEALTH DATA EXTRACTION: RUNNING
SOURCES: Google Fit, Samsung Health
DATA RANGE: 2 YEARS
STEPS TOTAL: 8,445,891
HEART RATE RECORDS: 234,891
SLEEP RECORDS: 680 NIGHTS
SAVED: /Evidence/health/health_data.json
```

**Note:** Heart rate and step data can be used to infer activity patterns and approximate location (e.g., no steps = stationary).

---

## for_041 — Calendar & Events

**Platform:** android/ios

**What it does:** Extracts all calendar events across all accounts (Google Calendar, iCloud, Exchange) including past, present, and future events with attendees and locations.

**How to run:**
1. Forensics → for_041
2. Select accounts: All / Specific
3. Include private events: Yes / No
4. Exports to JSON and ICS format

**Expected output:**
```
CALENDAR EXTRACTION: RUNNING
EVENTS: 2,445
ACCOUNTS: Google (1), Exchange (1)
FUTURE EVENTS: 34
SAVED: /Evidence/calendar/events.json
```

**Note:** Future calendar events reveal upcoming plans and locations — high value for active investigations.

---

## for_042 — Task Manager & Notes Data

**Platform:** android/ios

**What it does:** Extracts tasks, reminders, and to-do items from Google Tasks, Apple Reminders, Samsung Notes, and similar apps.

**How to run:**
1. Forensics → for_042
2. Scans all task and reminder app databases
3. Includes completed and deleted tasks if available
4. Exports full task list with creation timestamps

**Expected output:**
```
TASK/NOTES EXTRACTION: RUNNING
TASKS: 445
NOTES: 234
COMPLETED (RECOVERED): 89
SAVED: /Evidence/productivity/tasks.json
```

**Note:** Notes and tasks often contain sensitive to-do items, meeting notes, and personal reminders.

---

## for_043 — Notes App Extraction

**Platform:** android/ios

**What it does:** Full extraction of all notes from Google Keep, Apple Notes, Samsung Notes, Evernote, and other note-taking apps.

**How to run:**
1. Forensics → for_043
2. Includes text, images embedded in notes, sketches
3. Deleted notes attempted via WAL analysis
4. Exports in markdown and JSON format

**Expected output:**
```
NOTES EXTRACTION: RUNNING
GOOGLE KEEP: 89 NOTES
APPLE NOTES: [iOS only]
EVERNOTE: 234 NOTES
DELETED NOTES RECOVERED: 12
SAVED: /Evidence/productivity/notes.json
```

**Note:** Apple Notes supports rich content — images and sketches embedded in notes are extracted as separate files.

---

## for_044 — Password Manager Data

**Platform:** android/ios

**What it does:** Extracts data from installed password managers. Attempts to access encrypted vaults via extracted master key or cached unlock state.

**How to run:**
1. Forensics → for_044
2. Detects: 1Password, LastPass, Bitwarden, Dashlane, Keeper
3. Checks for cached unlock state (device recently unlocked)
4. Exports any accessible vault entries

**Expected output:**
```
PASSWORD MANAGER FORENSICS: RUNNING
APPS FOUND: LastPass, Bitwarden
VAULT STATUS: LOCKED
CACHED ENTRIES: 23 (FROM RECENT UNLOCK)
SAVED: /Evidence/credentials/password_manager.json
```

**Note:** Run immediately after device seizure — some managers cache unlock state for minutes/hours.

---

## for_045 — VPN App History

**Platform:** android/ios

**What it does:** Extracts VPN connection history, server configurations, and credentials from installed VPN apps.

**How to run:**
1. Forensics → for_045
2. Scans all recognized VPN app packages
3. Extracts server lists, connection logs, credentials
4. Identifies which VPN providers are used

**Expected output:**
```
VPN FORENSICS: RUNNING
VPN APPS: ExpressVPN, ProtonVPN
SERVERS USED: 12 LOCATIONS
CONNECTION LOG: 891 SESSIONS
CREDENTIALS: [if stored]
SAVED: /Evidence/network/vpn_history.json
```

**Note:** VPN usage timing may reveal when the user wanted anonymity — correlate with other activity logs.

---

## for_046 — Dating App Forensics

**Platform:** android/ios

**What it does:** Extracts profile data, match history, and conversations from Tinder, Bumble, Hinge, Grindr, and other dating apps.

**How to run:**
1. Forensics → for_046
2. Root/jailbreak required for private data
3. Extracts profile, matches, messages, GPS from app
4. Photo cache extracted as separate files

**Expected output:**
```
DATING APP FORENSICS: RUNNING
APPS FOUND: Tinder, Bumble
MATCHES: 234
MESSAGES: 4,891
PHOTOS CACHED: 891
SAVED: /Evidence/social/dating.json
```

**Note:** Dating apps store highly sensitive personal data — handle with appropriate discretion.

---

## for_047 — Gaming App Save Data

**Platform:** android/ios

**What it does:** Extracts game save files, achievement data, in-app purchase history, and online account credentials from gaming apps.

**How to run:**
1. Forensics → for_047
2. Scans all gaming app data directories
3. Extracts save files and purchase receipts
4. Identifies linked gaming accounts (Google Play Games, Apple Game Center)

**Expected output:**
```
GAMING FORENSICS: RUNNING
GAMING APPS: 23
SAVE FILES: 45
PURCHASE RECEIPTS: 89
ACCOUNTS: [Google Play Games identified]
SAVED: /Evidence/apps/gaming.json
```

**Note:** In-app purchase records are timestamped and tied to payment accounts — useful for financial correlation.

---

## for_048 — Streaming App History

**Platform:** android/ios

**What it does:** Extracts viewing history, search queries, and account data from Netflix, Spotify, YouTube, Disney+, and similar streaming apps.

**How to run:**
1. Forensics → for_048
2. Extracts from local app databases and caches
3. Viewing/listening history compiled with timestamps
4. Linked account email addresses identified

**Expected output:**
```
STREAMING FORENSICS: RUNNING
NETFLIX HISTORY: 445 TITLES
SPOTIFY HISTORY: 8,891 TRACKS
YOUTUBE HISTORY: 12,445 VIDEOS
SAVED: /Evidence/media/streaming_history.json
```

**Note:** Streaming history can establish behavioral patterns and potentially alibi/contradict alibis.

---

## for_049 — Shopping App Orders

**Platform:** android/ios

**What it does:** Extracts order history, shipping addresses, payment method metadata, and wishlists from Amazon, eBay, Etsy, and other shopping apps.

**How to run:**
1. Forensics → for_049
2. Scans shopping app local databases
3. Extracts full order history with addresses
4. Identifies saved payment methods

**Expected output:**
```
SHOPPING FORENSICS: RUNNING
AMAZON: 234 ORDERS
EBAY: 45 ORDERS
SHIPPING ADDRESSES: 8
SAVED: /Evidence/financial/shopping.json
```

**Note:** Shipping addresses reveal physical locations — often more reliable than GPS data.

---

## for_050 — Travel App Data

**Platform:** android/ios

**What it does:** Extracts booking history from Airbnb, Booking.com, Hotels.com, Expedia, and airline apps.

**How to run:**
1. Forensics → for_050
2. Scans travel app databases
3. Extracts past and upcoming bookings with addresses
4. Flight history compiled from airline apps

**Expected output:**
```
TRAVEL FORENSICS: RUNNING
AIRBNB BOOKINGS: 12
HOTEL BOOKINGS: 8
FLIGHTS: 23
LOCATIONS: 34 UNIQUE ADDRESSES
SAVED: /Evidence/location/travel_history.json
```

**Note:** Travel bookings are time-stamped and location-specific — excellent for timeline reconstruction.

---

## for_051 — Document App Extraction

**Platform:** android/ios

**What it does:** Extracts documents from Microsoft Office apps, Google Docs, Adobe Reader, and file manager apps.

**How to run:**
1. Forensics → for_051
2. Scans document app storage
3. Extracts DOCX, XLSX, PPTX, PDF files
4. Metadata extracted from each document (author, edit history)

**Expected output:**
```
DOCUMENT EXTRACTION: RUNNING
WORD DOCS: 89
EXCEL FILES: 45
PDFS: 123
AUTHOR METADATA: extracted
SAVED: /Evidence/documents/
```

**Note:** Document edit history and author metadata can reveal who created or modified files.

---

## for_052 — Voice Memo Recordings

**Platform:** android/ios

**What it does:** Extracts voice memo recordings with timestamps and transcription (if available) from the native Voice Memo app and third-party recording apps.

**How to run:**
1. Forensics → for_052
2. Scans native and third-party recording apps
3. Extracts audio files with full metadata
4. Auto-transcription via Singularity AI (optional)

**Expected output:**
```
VOICE MEMO EXTRACTION: RUNNING
RECORDINGS: 45
TOTAL DURATION: 12 hours 34 min
OLDEST: [timestamp]
AUTO-TRANSCRIPT: generating...
SAVED: /Evidence/audio/voice_memos/
```

**Note:** Voice recordings often contain highly sensitive conversations — auto-transcribe for keyword search.

---

## for_053 — Video Recording Metadata

**Platform:** android/ios

**What it does:** Extracts metadata from all video files: GPS location, camera model, recording timestamp, resolution, and whether videos were processed/edited after recording.

**How to run:**
1. Forensics → for_053
2. Scans all video files on device
3. Extracts metadata from MP4/MOV/AVI files
4. Flags videos where metadata was modified post-capture

**Expected output:**
```
VIDEO METADATA: RUNNING
VIDEOS SCANNED: 1,204
WITH GPS: 891
EDITED AFTER CAPTURE: 12
SAVED: /Evidence/media/video_metadata.json
```

**Note:** Video metadata is often richer than photo EXIF — includes stabilization data, lens info, and audio track metadata.

---

## for_054 — Screen Recording Cache

**Platform:** android

**What it does:** Extracts screen recording files and screenshots from the device, including system-generated screenshots from app switcher and accessibility services.

**How to run:**
1. Forensics → for_054
2. Scans Screenshots/, Screen recordings/, and accessibility cache
3. Timestamps and app context extracted where available
4. Exports all found recordings and screenshots

**Expected output:**
```
SCREEN RECORDING EXTRACTION: RUNNING
SCREENSHOTS: 892
SCREEN RECORDINGS: 23
ACCESSIBILITY CACHE: 445 FRAMES
SAVED: /Evidence/media/screen_captures/
```

**Note:** Accessibility service screenshots can reveal content from apps that block normal screenshots.

---

## for_055 — Bluetooth Pairing History

**Platform:** android/ios

**What it does:** Extracts the complete Bluetooth pairing database including device names, MAC addresses, pairing timestamps, and connection frequency.

**How to run:**
1. Forensics → for_055
2. Reads Bluetooth stack database
3. Lists all paired and previously paired devices
4. Identifies device types (headphones, car, watch, speaker)

**Expected output:**
```
BLUETOOTH FORENSICS: RUNNING
PAIRED DEVICES: 23
HISTORIC PAIRINGS: 45
CAR BLUETOOTH: [2 vehicles identified]
WATCH: [Apple Watch identified]
SAVED: /Evidence/wireless/bluetooth.json
```

**Note:** Car Bluetooth pairings reveal which vehicles were used — cross-reference with location data.

---

## for_056 — Wi-Fi Connection History

**Platform:** android/ios

**What it does:** Extracts the complete Wi-Fi connection history — every network ever connected to, with SSID, BSSID, timestamps, and signal strength logs.

**How to run:**
1. Forensics → for_056
2. Reads wpa_supplicant config and Wi-Fi scan history
3. Geolocates SSIDs using Wigle.net database (offline)
4. Maps connection history to locations

**Expected output:**
```
WI-FI HISTORY: RUNNING
NETWORKS SAVED: 89
CONNECTIONS LOGGED: 4,445
GEOLOCATED: 67/89 NETWORKS
HOME NETWORK: [identified]
SAVED: /Evidence/wireless/wifi_history.json
```

**Note:** Wi-Fi history is one of the best location indicators — every saved network reveals a place visited.

---

## for_057 — NFC Transaction Logs

**Platform:** android

**What it does:** Extracts NFC tap-to-pay transaction logs, transit card data, and NFC tag interaction history.

**How to run:**
1. Forensics → for_057
2. Scans Android HCE (Host Card Emulation) logs
3. Extracts Google Pay and Samsung Pay transaction metadata
4. Transit card usage extracted if supported

**Expected output:**
```
NFC TRANSACTION LOG: RUNNING
GOOGLE PAY TAPS: 234
TRANSIT TAPS: 89
NFC TAG READS: 12
SAVED: /Evidence/wireless/nfc_log.json
```

**Note:** Payment transaction timestamps and locations (merchant data) provide precise location and time evidence.

---

## for_058 — USB Connection History

**Platform:** android

**What it does:** Extracts USB connection history from the Android USB manager database, identifying every device that was connected via USB.

**How to run:**
1. Forensics → for_058
2. Reads USB device manager database
3. Lists connected devices with timestamps
4. Identifies USB storage devices, computers, accessories

**Expected output:**
```
USB CONNECTION HISTORY: RUNNING
DEVICES CONNECTED: 45
STORAGE DEVICES: 8
COMPUTERS (ADB): 12
LAST CONNECTION: [timestamp]
SAVED: /Evidence/system/usb_history.json
```

**Note:** Computer connections via ADB reveal which computers were connected — cross-reference with those systems.

---

## for_059 — Peripheral Device Log

**Platform:** android

**What it does:** Comprehensive log of all peripheral interactions: headphones, cases, stylus, smartwatches, and IoT accessories.

**How to run:**
1. Forensics → for_059
2. Scans all peripheral manager databases
3. Lists connected accessories with timestamps
4. Identifies smartwatch data sync events

**Expected output:**
```
PERIPHERAL LOG: RUNNING
PERIPHERALS LOGGED: 34
SMARTWATCH SYNCS: 891 EVENTS
HEADPHONE CONNECTIONS: 234
SAVED: /Evidence/system/peripheral_log.json
```

**Note:** Smartwatch sync timestamps match exactly with device usage — useful for timeline verification.

---

## for_060 — Network Traffic Log Recovery

**Platform:** android

**What it does:** Attempts to recover cached or logged network traffic data from VPN apps, proxy apps, and system network logs.

**How to run:**
1. Forensics → for_060
2. Scans for pcap files, traffic logs, proxy caches
3. Reconstructs HTTP requests where possible
4. Exports recovered traffic to .pcap format

**Expected output:**
```
NETWORK TRAFFIC RECOVERY: RUNNING
PCAP FILES FOUND: 3
PROXY CACHE: 892 MB
HTTP REQUESTS RECOVERED: 2,341
SAVED: /Evidence/network/traffic/
```

**Note:** VPN apps like NetGuard store traffic logs — check all network-related app directories.

---

## for_061 — ADB Backup Extraction

**Platform:** android

**What it does:** Extracts and parses ADB backup files (.ab) — including backups made by the device owner to a computer.

**How to run:**
1. Forensics → for_061
2. Looks for .ab files on device or connected storage
3. Decrypts backup if password-protected (brute force)
4. Extracts all app data from backup

**Expected output:**
```
ADB BACKUP EXTRACTION: RUNNING
BACKUP FILES FOUND: 2
ENCRYPTED: YES
BRUTE FORCE: running...
DECRYPTED: YES (password: [found])
APPS IN BACKUP: 67
SAVED: /Evidence/backups/adb/
```

**Note:** ADB backups include app private data not accessible via normal extraction — high value target.

---

## for_062 — iTunes Backup Parsing

**Platform:** ios

**What it does:** Parses iTunes/Finder backup files for iOS devices, extracting the full file system, keychain, and app data.

**How to run:**
1. Forensics → for_062
2. Locate backup: device storage or connected computer
3. Decrypt if encrypted (PIN or iTunes backup password needed)
4. Extract full file system from backup manifest

**Expected output:**
```
ITUNES BACKUP PARSING: RUNNING
BACKUP FOUND: [path]
ENCRYPTED: YES
DECRYPTION KEY: [via Keychain if available]
FILES IN BACKUP: 234,891
SAVED: /Evidence/backups/ios/
```

**Note:** Encrypted iTunes backups contain the keychain — the most valuable data in iOS forensics.

---

## for_063 — Android Backup Decryption

**Platform:** android

**What it does:** Decrypts password-protected Android ADB backups using known password attacks and device PIN correlation.

**How to run:**
1. Forensics → for_063
2. Provide path to encrypted .ab backup file
3. Try known PINs first, then dictionary attack
4. Outputs decrypted backup for parsing

**Expected output:**
```
BACKUP DECRYPTION: RUNNING
BACKUP: device_backup.ab
METHOD: PIN CORRELATION (device PIN)
ATTEMPTS: 3
STATUS: DECRYPTED
SAVED: /Evidence/backups/decrypted/
```

**Note:** Device PIN is often used as backup password — always try device PIN first.

---

## for_064 — Encrypted File Recovery

**Platform:** android/ios

**What it does:** Attempts to recover encryption keys for encrypted files on the device using keystore extraction and memory analysis.

**How to run:**
1. Forensics → for_064
2. Identify encrypted files/folders of interest
3. Module extracts Android Keystore / iOS Keychain keys
4. Attempts decryption with extracted keys

**Expected output:**
```
ENCRYPTED FILE RECOVERY: RUNNING
ENCRYPTED FILES: 23
KEYS EXTRACTED FROM KEYSTORE: 12
DECRYPTED: 8/23 FILES
SAVED: /Evidence/recovered/decrypted/
```

**Note:** Keys that were generated in hardware-backed keystore cannot be extracted — software-backed keys can.

---

## for_065 — Keychain Dump (iOS)

**Platform:** ios

**What it does:** Dumps the iOS Keychain — containing Wi-Fi passwords, app credentials, VPN passwords, certificates, and encryption keys.

**How to run:**
1. Forensics → for_065
2. Requires jailbreak for full keychain access
3. Decrypts all accessible keychain items
4. Exports as JSON with item classes and metadata

**Expected output:**
```
KEYCHAIN DUMP: RUNNING
ITEMS FOUND: 1,204
INTERNET PASSWORDS: 234
APP CREDENTIALS: 445
CERTIFICATES: 89
WI-FI PASSWORDS: 23
SAVED: /Evidence/credentials/keychain.json
```

**Note:** The iOS Keychain is the most sensitive data on the device — treat output with maximum security.

---

## for_066 — Android Keystore Analysis

**Platform:** android

**What it does:** Analyzes the Android Keystore, listing all stored keys with their properties (hardware-backed, purpose, expiry) and attempting to extract software-backed keys.

**How to run:**
1. Forensics → for_066
2. Root required
3. Lists all keystore entries with metadata
4. Extracts software-backed keys where possible

**Expected output:**
```
KEYSTORE ANALYSIS: RUNNING
KEYS FOUND: 89
HARDWARE-BACKED: 45 (cannot extract)
SOFTWARE-BACKED: 44 (extracted)
EXPIRED KEYS: 8
SAVED: /Evidence/credentials/keystore.json
```

**Note:** Hardware-backed keys are protected by the secure element — only software-backed keys can be extracted.

---

## for_067 — Secure Enclave Analysis

**Platform:** ios

**What it does:** Analyzes the iOS Secure Enclave, documenting what keys are stored and their access control policies.

**How to run:**
1. Forensics → for_067
2. Documents Secure Enclave key inventory
3. Reports access control constraints
4. Flags keys protected only by device passcode (may be vulnerable)

**Expected output:**
```
SECURE ENCLAVE ANALYSIS: RUNNING
KEYS IN ENCLAVE: 23
BIOBETRIC PROTECTED: 15
PASSCODE PROTECTED: 8
NO PROTECTION: 0
SAVED: /Evidence/credentials/secure_enclave.json
```

**Note:** Passcode-protected Secure Enclave keys are accessible after passcode bypass.

---

## for_068 — TrustZone Memory Forensics

**Platform:** android

**What it does:** Analyzes ARM TrustZone secure world memory artifacts accessible from normal world via TA (Trusted Application) forensics.

**How to run:**
1. Forensics → for_068
2. Requires root with TrustZone access
3. Enumerates loaded TAs and their capabilities
4. Attempts to extract TA data where policy allows

**Expected output:**
```
TRUSTZONE FORENSICS: RUNNING
TRUSTED APPS (TAs): 12
VENDOR TAs: 8
SECURITY KEYS: [policy-dependent]
SAVED: /Evidence/credentials/trustzone.json
```

**Note:** TrustZone analysis often reveals vendor-specific security implementations and potential bypass vectors.

---

## for_069 — Kernel Log Forensics

**Platform:** android

**What it does:** Captures and analyzes the Android kernel log (dmesg) for security events, USB connections, crash events, and driver anomalies.

**How to run:**
1. Forensics → for_069
2. Dumps full dmesg output
3. Parses for security-relevant events
4. Timeline of hardware events generated

**Expected output:**
```
KERNEL LOG FORENSICS: RUNNING
LOG SIZE: 512 KB
SECURITY EVENTS: 23
USB EVENTS: 45
CRASHES: 3
SAVED: /Evidence/system/dmesg.txt
```

**Note:** Kernel log rotates and is lost on reboot — capture immediately.

---

## for_070 — System Log Parsing

**Platform:** android

**What it does:** Parses Android system logs (/data/log/, dropbox, and event logs) for app crashes, permission denials, and system events.

**How to run:**
1. Forensics → for_070
2. Collects all system log sources
3. Parses and filters for security-relevant events
4. Timeline of system events generated

**Expected output:**
```
SYSTEM LOG PARSING: RUNNING
LOG SOURCES: 8
EVENTS PARSED: 234,891
PERMISSION DENIALS: 45
APP CRASHES: 234
SAVED: /Evidence/system/system_logs.json
```

**Note:** Permission denial logs reveal attempted unauthorized access by apps.

---

## for_071 — Application Crash Log Analysis

**Platform:** android/ios

**What it does:** Analyzes application crash logs (tombstones on Android, crash reports on iOS) for exploitable conditions and app-specific forensic artifacts.

**How to run:**
1. Forensics → for_071
2. Extracts all crash reports and tombstone files
3. Analyzes stack traces for memory artifacts
4. Flags crashes that may contain useful data

**Expected output:**
```
CRASH LOG ANALYSIS: RUNNING
CRASH REPORTS: 89
TOMBSTONES: 23
MEMORY ARTIFACTS IN TRACES: 12
SAVED: /Evidence/system/crash_analysis.json
```

**Note:** Crash logs sometimes contain memory snapshots with sensitive data embedded in stack traces.

---

## for_072 — ANR Log Analysis

**Platform:** android

**What it does:** Analyzes Android 'Application Not Responding' (ANR) logs which contain thread dumps — often revealing app internals and data in memory.

**How to run:**
1. Forensics → for_072
2. Extracts all ANR trace files from /data/anr/
3. Parses thread dumps for data artifacts
4. Identifies what the app was doing when it froze

**Expected output:**
```
ANR LOG ANALYSIS: RUNNING
ANR FILES: 12
THREAD DUMPS: 156
DATA ARTIFACTS: 8
SAVED: /Evidence/system/anr_analysis.json
```

**Note:** ANR traces contain full thread state — can reveal in-progress network requests, database queries, and in-memory data.

---

## for_073 — Tombstone File Analysis

**Platform:** android

**What it does:** Deep analysis of Android tombstone files (native crash dumps) for native code artifacts, memory contents, and crash forensics.

**How to run:**
1. Forensics → for_073
2. Extracts all tombstone files from /data/tombstones/
3. Parses native stack traces and memory maps
4. Attempts to extract strings from memory regions

**Expected output:**
```
TOMBSTONE ANALYSIS: RUNNING
TOMBSTONE FILES: 8
NATIVE CRASHES: 8
STRINGS EXTRACTED: 4,445
SAVED: /Evidence/system/tombstones/
```

**Note:** Strings in tombstones can contain URLs, credentials, and other artifacts from native code.

---

## for_074 — Bugreport Package Extraction

**Platform:** android

**What it does:** Extracts and parses Android bugreport packages — comprehensive system snapshots that include logs, system state, and app data.

**How to run:**
1. Forensics → for_074
2. Generates bugreport via ADB
3. Extracts and parses all components
4. Compiles forensic summary from bugreport data

**Expected output:**
```
BUGREPORT EXTRACTION: RUNNING
GENERATING BUGREPORT...
SIZE: 45 MB
COMPONENTS: 234 SECTIONS
FORENSIC ARTIFACTS: 89
SAVED: /Evidence/system/bugreport/
```

**Note:** Bugreport includes running process list, network connections, and system settings at time of capture.

---

## for_075 — Full Logcat Capture

**Platform:** android

**What it does:** Captures full Android logcat output across all buffers (main, system, events, crash, radio) for comprehensive runtime forensics.

**How to run:**
1. Forensics → for_075
2. Select capture duration or capture snapshot
3. All log buffers captured simultaneously
4. Filtered views generated for security events

**Expected output:**
```
LOGCAT CAPTURE: RUNNING
BUFFERS: main, system, events, crash, radio
ENTRIES: 892,445
SECURITY EVENTS: 234
SAVED: /Evidence/system/logcat_full.txt
```

**Note:** Radio buffer reveals cellular tower connections — corroborates or contradicts location data.

---

## for_076 — Network Interface Statistics

**Platform:** android

**What it does:** Extracts network interface statistics, traffic counters, and connection state for all network interfaces.

**How to run:**
1. Forensics → for_076
2. Reads /proc/net/ and network stats database
3. Traffic per-app breakdown available
4. Historical data extracted from netstats database

**Expected output:**
```
NETWORK INTERFACE STATS: RUNNING
INTERFACES: wlan0, rmnet0, eth0
PER-APP DATA USAGE: extracted
HISTORY: 3 MONTHS
SAVED: /Evidence/network/interface_stats.json
```

**Note:** Per-app data usage history can reveal hidden app activity (high data usage = active exfiltration?).

---

## for_077 — ARP Cache Dump

**Platform:** android

**What it does:** Dumps the current ARP cache and historical ARP entries, revealing devices on the same network.

**How to run:**
1. Forensics → for_077
2. Reads /proc/net/arp and neigh tables
3. Resolves MAC addresses to vendor (OUI lookup)
4. Maps network devices found

**Expected output:**
```
ARP CACHE DUMP: RUNNING
ARP ENTRIES: 23
VENDOR RESOLVED: 20/23
DEVICES: [Router: Netgear], [TV: Samsung], [Laptop: Apple]
SAVED: /Evidence/network/arp_cache.json
```

**Note:** ARP cache reveals what devices were on the local network during the capture window.

---

## for_078 — DNS Cache Recovery

**Platform:** android

**What it does:** Recovers DNS query history from the device's DNS resolver cache and from browser DNS caches.

**How to run:**
1. Forensics → for_078
2. Reads system DNS cache and browser caches
3. Builds list of all domains queried
4. Timestamps attached where available

**Expected output:**
```
DNS CACHE RECOVERY: RUNNING
SYSTEM DNS: 234 ENTRIES
CHROME DNS: 891 ENTRIES
UNIQUE DOMAINS: 1,204
SAVED: /Evidence/network/dns_cache.json
```

**Note:** DNS cache reveals what websites and services the device contacted — even for apps, not just browsers.

---

## for_079 — Firewall Rule Analysis

**Platform:** android

**What it does:** Analyzes iptables/nftables firewall rules currently active on the device, identifying custom rules that may indicate VPN, tethering, or security tools.

**How to run:**
1. Forensics → for_079
2. Dumps iptables -L -n -v for all tables
3. Analyzes rules for anomalies
4. Identifies VPN kill-switch and ad-block rules

**Expected output:**
```
FIREWALL ANALYSIS: RUNNING
RULES: 234
VPN KILL SWITCH: DETECTED
AD BLOCK RULES: 1,204 ENTRIES
CUSTOM RULES: 12
SAVED: /Evidence/network/firewall_rules.txt
```

**Note:** Custom firewall rules often reveal security tools and privacy configurations the user has set up.

---

## for_080 — VPN Connection Log

**Platform:** android

**What it does:** Extracts detailed VPN connection logs including server IPs, connection timestamps, duration, and data transferred.

**How to run:**
1. Forensics → for_080
2. Scans all VPN app databases
3. System VPN connection log extracted
4. Server locations geolocated

**Expected output:**
```
VPN CONNECTION LOG: RUNNING
VPN CONNECTIONS: 234
SERVERS: 45 IPs
GEOLOCATED: Netherlands, Switzerland, USA
TOTAL DATA: 234 GB
SAVED: /Evidence/network/vpn_log.json
```

**Note:** VPN connection gaps (times when VPN was disconnected) may reveal true IP exposure windows.

---

## for_081 — Email Header Analysis

**Platform:** android/ios

**What it does:** Parses email headers from extracted email databases to extract sender IP addresses, mail server chains, and email client fingerprints.

**How to run:**
1. Forensics → for_081
2. Requires emails already extracted (run for_015 first)
3. Parses Received headers from all emails
4. Extracts originating IPs and routes

**Expected output:**
```
EMAIL HEADER ANALYSIS: RUNNING
EMAILS ANALYZED: 12,445
ORIGINATING IPs: 891 UNIQUE
MAIL SERVERS: 234
SAVED: /Evidence/email/header_analysis.json
```

**Note:** Originating IPs in email headers can reveal sender locations even when display info is spoofed.

---

## for_082 — Email Attachment Extraction

**Platform:** android/ios

**What it does:** Extracts all email attachments from all email apps with full metadata including sender, date, and subject.

**How to run:**
1. Forensics → for_082
2. Requires email extraction (for_015) to be complete
3. Extracts all attachment types: docs, images, archives
4. Scans attachments for malware indicators

**Expected output:**
```
EMAIL ATTACHMENT EXTRACTION: RUNNING
ATTACHMENTS: 891
DOCUMENTS: 234
IMAGES: 445
ARCHIVES: 89
MALWARE FLAGGED: 2
SAVED: /Evidence/email/attachments/
```

**Note:** Archive attachments (.zip, .7z) are extracted and contents catalogued automatically.

---

## for_083 — Calendar Invite Analysis

**Platform:** android/ios

**What it does:** Analyzes calendar invites for attendee lists, organizer details, meeting links, and location data.

**How to run:**
1. Forensics → for_083
2. Parses all ICS/VCAL data from calendar extraction
3. Extracts attendee email addresses
4. Maps meeting locations

**Expected output:**
```
CALENDAR INVITE ANALYSIS: RUNNING
INVITES ANALYZED: 234
ATTENDEES: 1,204 UNIQUE
MEETING LINKS: 89 (Zoom/Teams/Meet)
LOCATIONS: 45
SAVED: /Evidence/calendar/invite_analysis.json
```

**Note:** Meeting attendee lists reveal professional and personal networks not visible in contacts.

---

## for_084 — Contact Relationship Mapping

**Platform:** android/ios

**What it does:** Builds a relationship graph from contacts, call logs, messages, and email showing who the target communicates with and how frequently.

**How to run:**
1. Forensics → for_084
2. Aggregates from contacts, calls, SMS, email
3. Weights relationships by communication frequency
4. Exports relationship graph as JSON and GraphML

**Expected output:**
```
RELATIONSHIP MAP: BUILDING
CONTACTS: 1,204
COMMUNICATION EVENTS: 45,891
UNIQUE RELATIONSHIPS: 892
STRONGEST: [person - 2,341 interactions]
SAVED: /Evidence/social/relationship_map.graphml
```

**Note:** GraphML file can be opened in Gephi or Cytoscape for visual network analysis.

---

## for_085 — Call Recording Extraction

**Platform:** android

**What it does:** Extracts call recordings made by call recording apps and the native call recorder (where available).

**How to run:**
1. Forensics → for_085
2. Scans all call recording app directories
3. Extracts audio files with call metadata
4. Cross-references with call log for attribution

**Expected output:**
```
CALL RECORDING EXTRACTION: RUNNING
RECORDINGS FOUND: 234
TOTAL DURATION: 45 hours
CALL RECORDER APPS: 2
SAVED: /Evidence/audio/call_recordings/
```

**Note:** Some recording apps encrypt files — decryption attempted using extracted app keys.

---

## for_086 — Voicemail Forensics

**Platform:** android/ios

**What it does:** Extracts voicemail audio files and transcriptions from visual voicemail apps.

**How to run:**
1. Forensics → for_086
2. Extracts from native and third-party visual voicemail
3. Audio files and transcriptions extracted
4. Caller number and timestamp attributed

**Expected output:**
```
VOICEMAIL FORENSICS: RUNNING
VOICEMAILS: 45
TRANSCRIPTIONS: 38 AVAILABLE
OLDEST: [timestamp]
SAVED: /Evidence/audio/voicemail/
```

**Note:** Voicemails often persist much longer than regular calls — good source of historical audio.

---

## for_087 — DTMF Tone Analysis

**Platform:** android

**What it does:** Analyzes audio recordings and voicemails for embedded DTMF tones — can reveal entered phone numbers, PINs, and extension codes.

**How to run:**
1. Forensics → for_087
2. Provide audio file or select from Evidence/audio/
3. Module detects and decodes DTMF sequences
4. Outputs decoded digit sequences

**Expected output:**
```
DTMF ANALYSIS: RUNNING
AUDIO FILE: [input]
DTMF SEQUENCES FOUND: 3
DECODED: 1234 | 7890 | 5551234567
SAVED: /Evidence/audio/dtmf_decoded.json
```

**Note:** DTMF sequences in voicemails may reveal PINs entered during automated phone banking.

---

## for_088 — SIM Card History

**Platform:** android

**What it does:** Extracts SIM card history from Android's telephony database, including SIM changes, previous SIM card ICCIDs, and carrier changes.

**How to run:**
1. Forensics → for_088
2. Reads telephony.db and settings database
3. Lists all SIMs ever used in device
4. Carrier change timeline generated

**Expected output:**
```
SIM HISTORY: RUNNING
CURRENT SIM: [ICCID]
PREVIOUS SIMs: 3 FOUND
CARRIER CHANGES: 5
SAVED: /Evidence/sim/sim_history.json
```

**Note:** SIM change history can reveal attempts to change identity or evade surveillance.

---

## for_089 — IMSI/IMEI History

**Platform:** android

**What it does:** Extracts the device's IMEI, IMSI, and any history of IMEI changes or modifications.

**How to run:**
1. Forensics → for_089
2. Reads baseband properties and telephony database
3. Checks for IMEI modification indicators
4. Reports all associated identifiers

**Expected output:**
```
IMSI/IMEI HISTORY: RUNNING
IMEI: [reported]
IMEI MODIFIED: NO INDICATORS
IMSI: [current SIM]
DEVICE ID HISTORY: extracted
SAVED: /Evidence/sim/imei_history.json
```

**Note:** IMEI changes are rare and significant — flag them prominently in reports.

---

## for_090 — Carrier Network Logs

**Platform:** android

**What it does:** Extracts carrier network connection logs from the radio layer, including tower connections, handovers, and signal quality history.

**How to run:**
1. Forensics → for_090
2. Reads radio interface layer (RIL) logs
3. Extracts tower connection history
4. Cell ID timeline generated

**Expected output:**
```
CARRIER NETWORK LOGS: RUNNING
RIL LOG ENTRIES: 234,891
TOWER CONNECTIONS: 4,445
HANDOVERS: 1,204
SAVED: /Evidence/cellular/carrier_logs.json
```

**Note:** Tower connection logs can triangulate approximate locations without GPS — useful when GPS was disabled.

---

## for_091 — RAM Capture (Live)

**Platform:** android

**What it does:** Captures the current RAM contents of the running device for memory forensics analysis.

**How to run:**
1. Forensics → for_091
2. Requires root and appropriate kernel support
3. Dumps /proc/[pid]/mem for all processes
4. Full memory image created

**Expected output:**
```
RAM CAPTURE: RUNNING
RAM SIZE: 12 GB
ACTIVE PROCESSES: 287
CAPTURING...
SAVED: /Evidence/memory/ram_dump.img
```

**Note:** Run immediately — RAM content changes constantly. Most valuable for capturing running process data.

---

## for_092 — Process Memory Dump

**Platform:** android

**What it does:** Dumps the memory of specific processes — useful for extracting encryption keys, credentials, and application state.

**How to run:**
1. Forensics → for_092
2. Select target process from running process list
3. Dumps all readable memory segments
4. Strings extracted automatically

**Expected output:**
```
PROCESS MEMORY DUMP: RUNNING
TARGET: [selected process]
MEMORY SEGMENTS: 45
TOTAL SIZE: 234 MB
STRINGS EXTRACTED: 45,891
SAVED: /Evidence/memory/[proc]_memdump.bin
```

**Note:** Target high-security apps (banking, password manager) that may have decrypted data in memory.

---

## for_093 — Heap Analysis

**Platform:** android

**What it does:** Analyzes Java/Kotlin heap dumps from Android apps, extracting object graphs, stored strings, and sensitive data in memory.

**How to run:**
1. Forensics → for_093
2. Trigger heap dump via ADB or JDWP
3. Parse .hprof file for sensitive objects
4. Extract strings, credentials, and key material

**Expected output:**
```
HEAP ANALYSIS: RUNNING
HEAP DUMP: [app].hprof
OBJECTS: 2,445,891
SECRET STRINGS FOUND: 23
CREDENTIALS IN MEMORY: 3
SAVED: /Evidence/memory/heap_analysis.json
```

**Note:** Heap analysis often reveals decrypted credentials that are in memory even when stored encrypted.

---

## for_094 — Stack Trace Extraction

**Platform:** android

**What it does:** Captures thread stack traces from running processes, useful for understanding execution state and finding code injection points.

**How to run:**
1. Forensics → for_094
2. Select target process or dump all
3. JDWP or /proc/[pid]/stack used
4. Traces analyzed for security-relevant functions

**Expected output:**
```
STACK TRACE EXTRACTION: RUNNING
PROCESSES: 287
THREADS: 1,204
SECURITY FUNCTIONS ACTIVE: 8
SAVED: /Evidence/memory/stack_traces.json
```

**Note:** Active cryptographic functions in stack traces may contain key material in adjacent stack frames.

---

## for_095 — Memory String Extraction

**Platform:** android

**What it does:** Extracts all printable strings from a memory dump or live process memory — useful for finding credentials, URLs, and tokens.

**How to run:**
1. Forensics → for_095
2. Provide memory dump file or select live process
3. Minimum string length configurable (default: 8 chars)
4. High-value strings flagged automatically

**Expected output:**
```
MEMORY STRING EXTRACTION: RUNNING
MEMORY SOURCE: [input]
STRINGS FOUND: 8,445,891
FILTERED (MIN 8 CHARS): 234,891
HIGH-VALUE FLAGGED: 445
SAVED: /Evidence/memory/strings.txt
```

**Note:** Filter output for: password, token, key, secret, api_key, auth — these patterns find credentials quickly.

---

## for_096 — Code Injection Trace

**Platform:** android

**What it does:** Detects and traces code injection in running processes — identifies injected libraries, hooks, and memory patches.

**How to run:**
1. Forensics → for_096
2. Scans all running processes for injection indicators
3. Compares loaded libraries against known-good list
4. Reports anomalous memory regions

**Expected output:**
```
CODE INJECTION TRACE: RUNNING
PROCESSES SCANNED: 287
INJECTION DETECTED: 3 PROCESSES
ANOMALOUS LIBS: libfrida-gadget.so
HOOKS: 12 FUNCTIONS HOOKED
SAVED: /Evidence/memory/injection_trace.json
```

**Note:** Finding Frida gadget indicates someone is actively instrumenting the device's processes.

---

## for_097 — API Call Trace

**Platform:** android

**What it does:** Traces API calls made by target apps — records function calls, parameters, and return values for forensic reconstruction.

**How to run:**
1. Forensics → for_097
2. Select target app to trace
3. Module instruments app via Frida/ptrace
4. API call log generated in real time

**Expected output:**
```
API CALL TRACE: RUNNING
TARGET: [app]
INSTRUMENTED: YES
CALLS LOGGED: 45,891/min
SECURITY API CALLS: 234
SAVED: /Evidence/memory/api_trace.json
```

**Note:** API trace reveals exactly what an app is doing — especially useful for reverse engineering obfuscated apps.

---

## for_098 — System Call Log

**Platform:** android

**What it does:** Logs system calls made by processes using strace/ptrace, revealing all OS-level operations.

**How to run:**
1. Forensics → for_098
2. Select target process
3. Attach strace-equivalent to process
4. System call log generated with arguments

**Expected output:**
```
SYSCALL LOG: RUNNING
TARGET: [process]
SYSCALLS/SEC: 12,445
FILE OPENS: 891
NETWORK CALLS: 234
SAVED: /Evidence/memory/syscall_log.txt
```

**Note:** File access patterns in syscall log reveal what files an app is reading and writing.

---

## for_099 — Hook Detection

**Platform:** android

**What it does:** Detects function hooks, inline patches, and instrumentation frameworks (Frida, Xposed, LSPosed) on the device.

**How to run:**
1. Forensics → for_099
2. Scans all processes for hook indicators
3. Checks for Xposed/LSPosed modules
4. Reports all detected instrumentation

**Expected output:**
```
HOOK DETECTION: RUNNING
XPOSED FRAMEWORK: DETECTED
LSPOSED MODULES: 3 ACTIVE
FRIDA DETECTED: NO
INLINE HOOKS: 12 FOUND
SAVED: /Evidence/system/hook_detection.json
```

**Note:** Xposed/LSPosed modules can alter app behavior — document all active modules.

---

## for_100 — Rootkit Artifact Analysis

**Platform:** android

**What it does:** Deep scan for rootkit artifacts: modified system binaries, hidden processes, hidden files, and kernel module anomalies.

**How to run:**
1. Forensics → for_100
2. Compares system binaries against known-good hashes
3. Checks for hidden processes in /proc
4. Scans for hidden files and anomalous kernel modules

**Expected output:**
```
ROOTKIT ANALYSIS: RUNNING
SYSTEM BINARIES CHECKED: 892
MODIFIED BINARIES: 3
HIDDEN PROCESSES: 1
KERNEL MODULES ANOMALOUS: 2
SAVED: /Evidence/system/rootkit_analysis.json
```

**Note:** Modified system binaries are a strong rootkit indicator — hash compare against AOSP reference.

---

## for_101 — Anti-Forensic Detection

**Platform:** android/ios

**What it does:** Detects anti-forensic tools and behaviors: log wipers, evidence destroyers, file shredders, and screen lock auto-triggers.

**How to run:**
1. Forensics → for_101
2. Scans for known anti-forensic app packages
3. Checks for auto-wipe triggers
4. Reports detected anti-forensic measures

**Expected output:**
```
ANTI-FORENSIC DETECTION: RUNNING
ANTI-FORENSIC APPS: 2 FOUND
AUTO-WIPE TRIGGER: DETECTED (wrong PIN x10)
SELF-DESTRUCT MESSAGES: app detected
SAVED: /Evidence/system/anti_forensic.json
```

**Note:** Disable auto-wipe triggers before proceeding with extraction — check for_101 output first.

---

## for_102 — Log Tampering Detection

**Platform:** android

**What it does:** Detects whether system logs have been tampered with — deleted, modified, or selectively cleared.

**How to run:**
1. Forensics → for_102
2. Analyzes log continuity and timestamps
3. Detects gaps, deletions, and timestamp anomalies
4. Reports tampered log entries

**Expected output:**
```
LOG TAMPERING DETECTION: RUNNING
LOG GAPS DETECTED: 3
GAP 1: [timestamp range] - 4 hrs missing
TIMESTAMP ANOMALIES: 12
SAVED: /Evidence/system/log_tampering.json
```

**Note:** Log gaps are significant — document the exact time ranges where logs are missing.

---

## for_103 — Timestamp Manipulation Detection

**Platform:** android/ios

**What it does:** Detects file system timestamp manipulation — files whose modification times, access times, and creation times are inconsistent.

**How to run:**
1. Forensics → for_103
2. Analyzes all file timestamps across the device
3. Flags files where timestamps are inconsistent
4. Compares against adjacent file timestamps for context

**Expected output:**
```
TIMESTAMP ANALYSIS: RUNNING
FILES ANALYZED: 234,891
ANOMALIES: 23 FILES
SUSPICIOUS: [list of files with issues]
SAVED: /Evidence/system/timestamp_anomalies.json
```

**Note:** Timestomping (deliberate timestamp modification) is a strong indicator of evidence tampering.

---

## for_104 — File Metadata Recovery

**Platform:** android/ios

**What it does:** Recovers file metadata for deleted files from directory entries and file system journals.

**How to run:**
1. Forensics → for_104
2. Scans file system journal for deleted file entries
3. Recovers metadata: name, size, timestamps, owner
4. Partial content recovery attempted

**Expected output:**
```
FILE METADATA RECOVERY: RUNNING
JOURNAL ENTRIES: 45,891
DELETED FILES FOUND: 2,341
METADATA RECOVERED: 2,341
CONTENT RECOVERED: 891/2,341
SAVED: /Evidence/recovered/metadata.json
```

**Note:** Even without file content recovery, metadata reveals what files existed and when they were deleted.

---

## for_105 — Hash Verification

**Platform:** android/ios

**What it does:** Computes and verifies SHA-256 and MD5 hashes of all collected evidence files for chain-of-custody integrity.

**How to run:**
1. Forensics → for_105
2. Runs on all files in /Evidence/ directory
3. Hash manifest generated
4. Verifies against any existing hashes

**Expected output:**
```
HASH VERIFICATION: RUNNING
FILES HASHED: 4,891
MANIFEST GENERATED: YES
VERIFIED: 4,891/4,891 OK
SAVED: /Evidence/hashes/evidence_manifest.sha256
```

**Note:** Always run hash verification at the end of collection — required for forensic chain of custody.

---

## for_106 — Chain of Custody Documentation

**Platform:** android/ios

**What it does:** Generates a complete chain-of-custody document for all collected evidence including operator details, timestamps, and evidence descriptions.

**How to run:**
1. Forensics → for_106
2. Enter operator name and case reference
3. Module inventories all evidence with timestamps
4. Generates signed CoC document

**Expected output:**
```
CHAIN OF CUSTODY: GENERATING
OPERATOR: [entered]
CASE REF: [entered]
EVIDENCE ITEMS: 4,891
DOCUMENT: /Evidence/chain_of_custody.pdf
```

**Note:** Chain of custody document is legally required if evidence will be used in proceedings.

---

## for_107 — Evidence Packaging

**Platform:** android/ios

**What it does:** Packages all evidence into a structured, encrypted archive with manifest and hash verification.

**How to run:**
1. Forensics → for_107
2. Select encryption: AES-256 / None
3. Set archive password
4. All evidence packed into single encrypted archive

**Expected output:**
```
EVIDENCE PACKAGING: RUNNING
FILES: 4,891
TOTAL SIZE: 45 GB
ENCRYPTION: AES-256
ARCHIVE: /Evidence/case_[date].janus.enc
HASH: [SHA-256]
```

**Note:** Package immediately after collection — prevents accidental modification.

---

## for_108 — Secure Transfer Preparation

**Platform:** android/ios

**What it does:** Prepares evidence for secure transfer — splits large archives, creates checksums, and optionally encrypts for remote transfer.

**How to run:**
1. Forensics → for_108
2. Select transfer method: USB / Ghost-Net / Encrypted Upload
3. Split size configurable for USB transfer
4. Transfer manifest generated

**Expected output:**
```
SECURE TRANSFER PREP: RUNNING
ARCHIVE SIZE: 45 GB
SPLIT INTO: 45 x 1GB PARTS
CHECKSUMS: GENERATED
METHOD: USB TRANSFER
READY: YES
```

**Note:** Use Ghost-Net for secure wireless transfer between Pandora units.

---

## for_109 — Forensic Report Generator (Text)

**Platform:** android/ios

**What it does:** Generates a plain text forensic report summarizing all findings from the current operation.

**How to run:**
1. Forensics → for_109
2. Report auto-populated from Evidence folder
3. Select sections to include
4. Report saved as .txt

**Expected output:**
```
REPORT GENERATION: RUNNING
SECTIONS: 12
FINDINGS: 234
RECOMMENDATIONS: 8
SAVED: /Evidence/reports/forensic_report.txt
```

**Note:** Plain text format for maximum compatibility — readable on any system.

---

## for_110 — Forensic Report Generator (JSON)

**Platform:** android/ios

**What it does:** Generates a structured JSON forensic report — machine-readable format for integration with case management systems.

**How to run:**
1. Forensics → for_110
2. All evidence metadata included as structured data
3. Finding severity ratings included
4. JSON report saved

**Expected output:**
```
JSON REPORT: GENERATING
FINDINGS: 234
SEVERITY RATINGS: APPLIED
SCHEMA: JanusForensics/v2
SAVED: /Evidence/reports/forensic_report.json
```

**Note:** JSON report can be imported directly into forensic case management platforms.

---

## for_111 — Forensic Report Generator (HTML)

**Platform:** android/ios

**What it does:** Generates a rich HTML forensic report with embedded images, timelines, and interactive evidence viewer.

**How to run:**
1. Forensics → for_111
2. Embeds key evidence items directly in report
3. Timeline chart generated
4. Self-contained HTML file (no external dependencies)

**Expected output:**
```
HTML REPORT: GENERATING
EMBEDDED IMAGES: 45
TIMELINE CHART: GENERATED
INTERACTIVE: YES
SAVED: /Evidence/reports/forensic_report.html
```

**Note:** HTML report is the most presentation-ready format — ideal for briefings.

---

## for_112 — Forensic Report Generator (PDF)

**Platform:** android/ios

**What it does:** Generates a professional PDF forensic report formatted for legal and official use.

**How to run:**
1. Forensics → for_112
2. Enter case information (case number, examiner, date)
3. Professional layout applied
4. PDF saved with metadata

**Expected output:**
```
PDF REPORT: GENERATING
PAGES: ~120
CASE INFO: [entered]
FORMAT: A4 / Letter
SAVED: /Evidence/reports/forensic_report.pdf
```

**Note:** PDF report includes digital signature of the Janus operator — provides tamper evidence.

---

## for_113 — Timeline Visualization Generator

**Platform:** android/ios

**What it does:** Generates a comprehensive visual timeline of all events found across all data sources — correlating messages, location, calls, and app usage.

**How to run:**
1. Forensics → for_113
2. Select time range for timeline
3. Choose data sources to include
4. Timeline exported as HTML and JSON

**Expected output:**
```
TIMELINE GENERATOR: RUNNING
EVENTS: 234,891
DATA SOURCES: 12
TIME RANGE: [first event] to [last event]
SAVED: /Evidence/reports/timeline.html
```

**Note:** The master timeline is the most powerful analysis tool — it correlates all data into one view.

---

## for_114 — Network Map Generator

**Platform:** android/ios

**What it does:** Generates a visual network map of all networks and devices the target has connected to.

**How to run:**
1. Forensics → for_114
2. Aggregates from Wi-Fi history, Bluetooth, NFC
3. Devices geolocated where possible
4. Network map exported as SVG and JSON

**Expected output:**
```
NETWORK MAP: GENERATING
NETWORKS: 89
DEVICES: 234
GEOLOCATED: 67%
SAVED: /Evidence/reports/network_map.svg
```

**Note:** Network map reveals the target's digital environment — home, work, and social networks visible.

---

## for_115 — Social Graph Visualizer

**Platform:** android/ios

**What it does:** Builds and visualizes the target's social network from all communication data.

**How to run:**
1. Forensics → for_115
2. Aggregates contacts from all sources
3. Relationship weights calculated
4. Graph exported as GraphML and PNG

**Expected output:**
```
SOCIAL GRAPH: GENERATING
NODES: 892
EDGES: 4,445
CENTRAL NODE: [target]
TOP CONNECTION: [person]
SAVED: /Evidence/reports/social_graph.graphml
```

**Note:** Social graph reveals key relationships and communication hubs — useful for network investigation.

---

## for_116 — Photo Timeline Builder

**Platform:** android/ios

**What it does:** Creates a chronological timeline of all photos on the device with EXIF data, location, and camera metadata.

**How to run:**
1. Forensics → for_116
2. Processes all extracted photos
3. Timeline sorted by capture timestamp
4. Map view of photo locations included

**Expected output:**
```
PHOTO TIMELINE: BUILDING
PHOTOS: 8,445
WITH GPS: 3,221
DATE RANGE: [first] to [last]
SAVED: /Evidence/reports/photo_timeline.html
```

**Note:** Photo timeline with GPS creates a highly accurate movement history corroborated by visual evidence.

---

## for_117 — Communication Thread Visualizer

**Platform:** android/ios

**What it does:** Visualizes all communication threads — showing who the target talked to, when, and through which platform.

**How to run:**
1. Forensics → for_117
2. Aggregates all messaging platforms
3. Thread visualization with frequency heatmap
4. Exported as HTML interactive view

**Expected output:**
```
COMMS VISUALIZER: RUNNING
THREADS: 891
PLATFORMS: 8
MOST ACTIVE: [person] via WhatsApp
SAVED: /Evidence/reports/comms_visualizer.html
```

**Note:** Cross-platform view reveals the full communication picture — no single app shows everything.

---

## for_118 — Financial Transaction Timeline

**Platform:** android/ios

**What it does:** Creates a chronological timeline of all financial transactions found across all payment apps and banking apps.

**How to run:**
1. Forensics → for_118
2. Aggregates from banking, payment, crypto apps
3. Timeline built with amounts and parties
4. Suspicious transactions flagged by AI

**Expected output:**
```
FINANCIAL TIMELINE: BUILDING
TRANSACTIONS: 2,341
SOURCES: 5 APPS
DATE RANGE: [first] to [last]
FLAGGED: 12 SUSPICIOUS
SAVED: /Evidence/reports/financial_timeline.html
```

**Note:** AI flags large, unusual, or frequent transactions — review flagged items first.

---

## for_119 — Movement Pattern Map

**Platform:** android/ios

**What it does:** Creates a heatmap and pattern analysis of the target's physical movements from all location sources.

**How to run:**
1. Forensics → for_119
2. Aggregates GPS, Wi-Fi, cellular, and app location data
3. Heatmap of frequented locations generated
4. Regular routes and timing patterns identified

**Expected output:**
```
MOVEMENT MAP: BUILDING
LOCATION POINTS: 892,445
SOURCES: GPS, Wi-Fi, Cellular
HOME: [identified]
WORK: [identified]
SAVED: /Evidence/reports/movement_heatmap.html
```

**Note:** Movement pattern analysis reveals home, work, and regular destinations with high confidence.

---

## for_120 — Full Evidence Archive

**Platform:** android/ios

**What it does:** Creates the final comprehensive evidence archive — all files, reports, hashes, and chain of custody in one encrypted package.

**How to run:**
1. Forensics → for_120
2. Confirm all previous modules have run
3. Enter final case details
4. Archive generated and hash-verified

**Expected output:**
```
FINAL ARCHIVE: CREATING
FILES: 45,891
TOTAL SIZE: 120 GB
ENCRYPTION: AES-256-XTS
ARCHIVE HASH: [SHA-256]
SAVED: /Evidence/CASE_[REF]_FINAL.janus.enc
```

**Note:** This is the deliverable — the complete forensic package ready for handoff.

---

## for_121 — Live SMS Monitor

**Platform:** android

**What it does:** Real-time monitoring daemon that captures incoming and outgoing SMS messages as they occur.

**How to run:**
1. Forensics → for_121
2. Module runs as background daemon
3. New messages captured as they arrive
4. Alerts via Pandora haptic when keyword detected

**Expected output:**
```
LIVE SMS MONITOR: ACTIVE
MODE: REAL-TIME
KEYWORD ALERTS: [configured]
MESSAGES CAPTURED: [live counter]
LOG: /Evidence/live/sms_live.log
```

**Note:** Keyword alerts let you monitor for specific terms without watching the log continuously.

---

## for_122 — Real-Time Call Monitor

**Platform:** android

**What it does:** Monitors incoming and outgoing calls in real time — logs caller ID, timestamps, and optionally records audio.

**How to run:**
1. Forensics → for_122
2. Select monitoring mode: Log only / Log + Record
3. Runs as background daemon
4. Call log updated in real time

**Expected output:**
```
LIVE CALL MONITOR: ACTIVE
MODE: LOG + RECORD
CURRENT CALL: [none]
LOG: /Evidence/live/calls_live.log
```

**Note:** Recording mode captures call audio — stored in /Evidence/live/recordings/.

---

## for_123 — Real-Time Location Monitor

**Platform:** android/ios

**What it does:** Continuously logs device GPS location at configurable intervals.

**How to run:**
1. Forensics → for_123
2. Set polling interval: 10s / 30s / 60s / 5min
3. Runs as background daemon
4. Live KML track file updated continuously

**Expected output:**
```
LIVE LOCATION MONITOR: ACTIVE
INTERVAL: 30 SECONDS
CURRENT: [lat, lon, accuracy]
LOG: /Evidence/live/location_live.kml
```

**Note:** 30-second interval provides accurate movement tracking without excessive battery drain.

---

## for_124 — Real-Time Network Monitor

**Platform:** android

**What it does:** Monitors all network connections made by the device in real time — shows app, destination IP, domain, and data transferred.

**How to run:**
1. Forensics → for_124
2. Optionally filter by app
3. Runs as background daemon using VPN capture
4. Network activity log updated in real time

**Expected output:**
```
LIVE NETWORK MONITOR: ACTIVE
CONNECTIONS/MIN: 234
APPS ACTIVE: 23
TOP DESTINATION: [domain]
LOG: /Evidence/live/network_live.log
```

**Note:** VPN capture method works without root — captures all app network traffic transparently.

---

## for_125 — Real-Time Network Alert

**Platform:** android

**What it does:** Triggers alerts when specific domains, IPs, or data patterns are seen in network traffic.

**How to run:**
1. Forensics → for_125
2. Set alert rules: domain / IP / data pattern
3. Alert delivered via Pandora haptic and TUI
4. Matching traffic captured and saved

**Expected output:**
```
NETWORK ALERT MONITOR: ACTIVE
RULES: 5 CONFIGURED
ALERTS: [live counter]
LATEST: [domain matched rule]
LOG: /Evidence/live/alerts.log
```

**Note:** Combine with for_124 for both alerting and full capture.

---

## for_126 — Keyword Alert System

**Platform:** android

**What it does:** Monitors all incoming text content (SMS, notifications, messages) for configured keywords and triggers alerts.

**How to run:**
1. Forensics → for_126
2. Enter keyword list (supports regex)
3. Select sources: SMS / Notifications / All messages
4. Alert triggered on match

**Expected output:**
```
KEYWORD ALERT: ACTIVE
KEYWORDS: [configured]
SOURCES: SMS, Notifications
MATCHES SO FAR: [count]
LOG: /Evidence/live/keyword_matches.log
```

**Note:** Useful for operational surveillance — get alerted immediately when a key term appears.

---

## for_127 — Photo Capture Trigger

**Platform:** android/ios

**What it does:** Silently captures photos from front/rear camera on configured triggers (keyword, schedule, remote command).

**How to run:**
1. Forensics → for_127
2. Select camera: Front / Rear / Both
3. Set trigger: Schedule / Remote / Keyword
4. Photos saved silently to Evidence

**Expected output:**
```
PHOTO TRIGGER: ARMED
CAMERA: FRONT
TRIGGER: SCHEDULE (every 15 min)
PHOTOS CAPTURED: [live counter]
SAVED: /Evidence/live/photos/
```

**Note:** Front camera captures who is using the device — extremely useful for identity verification.

---

## for_128 — Audio Capture Trigger

**Platform:** android/ios

**What it does:** Silently captures audio via microphone on configured triggers.

**How to run:**
1. Forensics → for_128
2. Set trigger: Schedule / Keyword / Remote
3. Set duration: 30s / 60s / 5min / Until silence
4. Audio saved to Evidence

**Expected output:**
```
AUDIO TRIGGER: ARMED
TRIGGER: KEYWORD DETECTED
DURATION: 60 SECONDS
RECORDINGS: [live counter]
SAVED: /Evidence/live/audio/
```

**Note:** Keyword trigger activates recording when the target mentions configured terms.

---

## for_129 — Movement Alert

**Platform:** android/ios

**What it does:** Triggers an alert when the target device moves beyond a configured geofence boundary.

**How to run:**
1. Forensics → for_129
2. Set center point: current location / custom coordinates
3. Set radius: 100m / 500m / 1km / custom
4. Alert delivered via Pandora haptic when boundary crossed

**Expected output:**
```
MOVEMENT ALERT: ARMED
CENTER: [current location]
RADIUS: 500m
STATUS: WITHIN BOUNDARY
LOG: /Evidence/live/movement_alerts.log
```

**Note:** Geofence alerting lets you know immediately when the target leaves or enters a defined area.

---

## for_130 — Network Change Alert

**Platform:** android

**What it does:** Alerts when the device connects to a new or unknown Wi-Fi network or changes cellular towers.

**How to run:**
1. Forensics → for_130
2. Whitelist known networks (optional)
3. Alert on any new network connection
4. New network details captured on alert

**Expected output:**
```
NETWORK CHANGE ALERT: ARMED
WHITELISTED: 3 NETWORKS
STATUS: MONITORING
ALERTS: [live counter]
LOG: /Evidence/live/network_changes.log
```

**Note:** Alerts when the target goes somewhere new — useful for tracking movement without continuous GPS monitoring.

---

## for_131 — iOS Jailbreak Detection Bypass

**Platform:** ios

**What it does:** Bypasses jailbreak detection in apps that refuse to run on jailbroken devices — allows forensic tools to operate transparently.

**How to run:**
1. Forensics → for_131
2. Module patches jailbreak detection in all installed apps
3. Uses Shadow/Liberty Lite techniques
4. Apps now run normally alongside forensic tools

**Expected output:**
```
JAILBREAK DETECTION BYPASS: RUNNING
APPS PATCHED: 45
BETA TECHNIQUES USED: Shadow, Liberty
STATUS: JB DETECTION DISABLED
APPS: OPERATIONAL
```

**Note:** Some banking apps have server-side jailbreak detection — local patch may not fully help.

---

## for_132 — iOS Trust Re-Establishment

**Platform:** ios

**What it does:** Re-establishes the libimobiledevice trust relationship with an iOS device — required when trust has been revoked.

**How to run:**
1. Forensics → for_132
2. Connect iOS device via USB
3. Module generates new pairing record
4. Trust established without user interaction (exploit-based)

**Expected output:**
```
TRUST ESTABLISHMENT: RUNNING
DEVICE: [identified]
METHOD: PAIRING EXPLOIT
PAIRING RECORD: CREATED
STATUS: TRUSTED
```

**Note:** Trust must be established before any other iOS forensic module can run.

---

## for_133 — iOS Backup Encryption Key Recovery

**Platform:** ios

**What it does:** Attempts to recover the iOS backup encryption key from the device keychain or by brute-forcing a known PIN.

**How to run:**
1. Forensics → for_133
2. Try keychain extraction first (requires jailbreak)
3. If locked, try PIN brute force (4-6 digit)
4. Key recovered for use with for_062

**Expected output:**
```
BACKUP KEY RECOVERY: RUNNING
METHOD: KEYCHAIN EXTRACTION
KEY: FOUND
BACKUP DECRYPTION: ENABLED
SAVED: /Evidence/credentials/ios_backup_key.txt
```

**Note:** Encrypted backups contain the keychain — the most sensitive data on iOS.

---

## for_134 — iOS Activation Lock Audit

**Platform:** ios

**What it does:** Audits the iOS Activation Lock status and identifies the associated Apple ID — useful for device ownership determination.

**How to run:**
1. Forensics → for_134
2. Reads Activation Lock status from device
3. Associated Apple ID domain identified
4. IMEI checked against Apple's public lookup

**Expected output:**
```
ACTIVATION LOCK AUDIT: RUNNING
STATUS: LOCKED
APPLE ID: [domain portion]
IMEI: [reported]
LOCK STATUS CONFIRMED: YES
```

**Note:** Activation Lock status helps establish device ownership for forensic reports.

---

## for_135 — iOS MDM Profile Analysis

**Platform:** ios

**What it does:** Extracts and analyzes Mobile Device Management (MDM) profiles installed on the device — reveals corporate enrollment and remote management capabilities.

**How to run:**
1. Forensics → for_135
2. Extracts all installed configuration and MDM profiles
3. Reports MDM server URL and capabilities
4. Identifies remote wipe capability

**Expected output:**
```
MDM PROFILE ANALYSIS: RUNNING
PROFILES: 3
MDM ENROLLED: YES
SERVER: [MDM URL]
REMOTE WIPE: CAPABLE
SAVED: /Evidence/system/mdm_profiles.json
```

**Note:** If MDM remote wipe is capable, handle device with caution — disconnect from network immediately.

---

## for_136 — Android SafetyNet Bypass

**Platform:** android

**What it does:** Bypasses Android SafetyNet/Play Integrity attestation — allows rooted devices to pass integrity checks.

**How to run:**
1. Forensics → for_136
2. Module patches Play Services SafetyNet
3. Uses MagiskHide / Zygisk techniques
4. Device passes attestation after patch

**Expected output:**
```
SAFETYNET BYPASS: RUNNING
TECHNIQUE: Zygisk + DenyList
ATTESTATION: PASSING
BANKING APPS: OPERATIONAL
STATUS: BYPASS ACTIVE
```

**Note:** Required to use banking and payment apps on rooted devices during forensic sessions.

---

## for_137 — Android SELinux Policy Audit

**Platform:** android

**What it does:** Audits the active Android SELinux policy — identifies permissive domains, policy violations, and bypass opportunities.

**How to run:**
1. Forensics → for_137
2. Dumps current SELinux policy
3. Analyzes for permissive domains
4. Reports policy violations and bypasses

**Expected output:**
```
SELINUX AUDIT: RUNNING
POLICY: ENFORCING
PERMISSIVE DOMAINS: 3
POLICY VIOLATIONS: 12
BYPASS OPPORTUNITIES: 2
SAVED: /Evidence/system/selinux_audit.json
```

**Note:** Permissive SELinux domains are common on rooted devices — document them for forensic context.

---

## for_138 — Android Signature Verification Bypass

**Platform:** android

**What it does:** Bypasses APK signature verification to allow installation of modified or repackaged APKs.

**How to run:**
1. Forensics → for_138
2. Module patches signature verification in Package Manager
3. Modified APKs can now be installed
4. Restore original behavior when done

**Expected output:**
```
SIGNATURE BYPASS: RUNNING
PACKAGE MANAGER: PATCHED
SIGNATURE CHECK: DISABLED
MODIFIED APKS: INSTALLABLE
RESTORE: run module again to restore
```

**Note:** Use with care — signature bypass allows any APK to be installed, including malicious ones.

---

## for_139 — Android Verified Boot Analysis

**Platform:** android

**What it does:** Analyzes Android Verified Boot (AVB) state — reports boot integrity and identifies modifications.

**How to run:**
1. Forensics → for_139
2. Reads AVB state via ADB
3. Checks dm-verity status on partitions
4. Reports any partition modifications

**Expected output:**
```
VERIFIED BOOT ANALYSIS: RUNNING
AVB STATE: ORANGE (modified)
DM-VERITY: DISABLED
MODIFIED PARTITIONS: boot, system
SAVED: /Evidence/system/avb_analysis.json
```

**Note:** AVB state 'orange' means bootloader is unlocked — important forensic context for evidence integrity.

---

## for_140 — Factory Reset Detection

**Platform:** android

**What it does:** Detects whether the device has been factory reset and estimates when based on residual artifacts.

**How to run:**
1. Forensics → for_140
2. Checks for factory reset indicators
3. Estimates reset timestamp from residual data
4. Reports what data may have been wiped

**Expected output:**
```
FACTORY RESET DETECTION: RUNNING
RESET DETECTED: YES
ESTIMATED DATE: [timestamp]
RESIDUAL ARTIFACTS: 23 FOUND
SAVED: /Evidence/system/factory_reset.json
```

**Note:** Factory reset does not always wipe all data — residual artifacts are worth investigating.

---

## for_141 — Recovery Mode Data Access

**Platform:** android

**What it does:** Accesses device data through recovery mode — bypasses Android security when device is booted to recovery.

**How to run:**
1. Forensics → for_141
2. Device must be in recovery mode
3. Extracts available partitions via ADB sideload
4. Data extraction from mounted partitions

**Expected output:**
```
RECOVERY MODE ACCESS: RUNNING
RECOVERY: CONFIRMED
PARTITIONS ACCESSIBLE: /cache, /data (if unencrypted)
EXTRACTION: RUNNING
SAVED: /Evidence/recovery/
```

**Note:** Recovery mode access is limited on encrypted devices — most effective on unencrypted or Qualcomm EDL targets.

---

## for_142 — Bootloader Forensics

**Platform:** android

**What it does:** Analyzes bootloader state, fastboot device information, and bootloader unlock history.

**How to run:**
1. Forensics → for_142
2. Boot device to fastboot mode
3. Extracts bootloader info via fastboot commands
4. Reports unlock state and any exploit indicators

**Expected output:**
```
BOOTLOADER FORENSICS: RUNNING
FASTBOOT: CONNECTED
BOOTLOADER: UNLOCKED
UNLOCK DATE: [if available]
CRITICAL PARTITIONS: extractable
SAVED: /Evidence/bootloader/
```

**Note:** Unlocked bootloader allows extraction of all partitions — use for_001 for full image.

---

## for_143 — EDL Mode Extraction (Qualcomm)

**Platform:** android

**What it does:** Qualcomm Emergency Download (EDL) mode extraction — bypasses Android entirely for raw partition access.

**How to run:**
1. Forensics → for_143
2. Trigger EDL mode (test point short or adb edl command)
3. Connect with Firehose protocol loader
4. Raw partition images extracted

**Expected output:**
```
EDL EXTRACTION: RUNNING
EDL MODE: CONFIRMED
FIREHOSE: LOADED
PARTITIONS: ALL ACCESSIBLE
EXTRACTING: /dev/sda (full)
SAVED: /Evidence/edl/
```

**Note:** EDL bypasses all Android security — most powerful extraction method for Qualcomm devices.

---

## for_144 — JTAG-Based Forensic Acquisition

**Platform:** android

**What it does:** Physical acquisition via JTAG debugging port — requires hardware access to the device PCB.

**How to run:**
1. Forensics → for_144
2. Attach JTAG adapter to device test points
3. Select JTAG profile for target CPU
4. Memory regions extracted via JTAG

**Expected output:**
```
JTAG ACQUISITION: RUNNING
JTAG CONNECTED: YES
TARGET CPU: [identified]
MEMORY: ACCESSIBLE
EXTRACTING...
SAVED: /Evidence/jtag/
```

**Note:** Requires Pandora Mk.1 with JTAG adapter. Consult hardware/pcb_spec.md for test point locations.

---

## for_145 — Chip-Off Acquisition Preparation

**Platform:** android

**What it does:** Prepares documentation and thermal profile for chip-off NAND extraction — the most invasive forensic technique.

**How to run:**
1. Forensics → for_145
2. Run first to document current state before chip-off
3. Generates chip removal guide for target device
4. Thermal profile for BGA rework station

**Expected output:**
```
CHIP-OFF PREP: RUNNING
TARGET DEVICE: [identified]
STORAGE CHIP: [eMMC/UFS identified]
THERMAL PROFILE: 220°C/30s
GUIDE: /Evidence/chipoff/removal_guide.pdf
```

**Note:** Chip-off is destructive — device cannot be reassembled. Last resort only.

---

## for_146 — NAND Flash Analysis

**Platform:** android

**What it does:** Analyzes raw NAND flash dumps — handles bad blocks, ECC correction, and wear-leveling reconstruction.

**How to run:**
1. Forensics → for_146
2. Provide raw NAND dump file
3. Module applies ECC correction
4. Reconstructs logical layout from raw flash

**Expected output:**
```
NAND ANALYSIS: RUNNING
NAND DUMP: [input file]
SIZE: 64 GB
ECC CORRECTIONS: 1,204
BAD BLOCKS: 23
RECONSTRUCTED: /Evidence/nand/reconstructed.img
```

**Note:** NAND analysis is computationally intensive — runs on Hailo-8 for acceleration.

---

## for_147 — eMMC Forensics

**Platform:** android

**What it does:** Analyzes eMMC storage dumps including partition table recovery, data reconstruction, and deleted data recovery.

**How to run:**
1. Forensics → for_147
2. Provide eMMC dump (from for_001 or chip-off)
3. Parses GPT/MBR partition table
4. Mounts each partition for analysis

**Expected output:**
```
eMMC FORENSICS: RUNNING
DUMP: [input]
PARTITIONS: 28 FOUND
MOUNTED: /system, /data, /cache
ANALYSIS: RUNNING
SAVED: /Evidence/emmc/
```

**Note:** eMMC forensics is the foundation for all Android storage analysis — use with for_031 for file recovery.

---

## for_148 — SSD/NVMe Forensics

**Platform:** android

**What it does:** Analyzes NVMe storage from Pandora Titan's M.2 slots or externally connected NVMe drives.

**How to run:**
1. Forensics → for_148
2. Select target NVMe device
3. Imaging and partition analysis
4. S.M.A.R.T. data extracted for drive health history

**Expected output:**
```
NVMe FORENSICS: RUNNING
DEVICE: [NVMe identifier]
CAPACITY: 1 TB
SMART DATA: extracted
PARTITIONS: [found]
SAVED: /Evidence/nvme/
```

**Note:** S.M.A.R.T. data reveals drive usage history — hours of use and power cycle count.

---

## for_149 — Full Evidence Correlation Engine

**Platform:** android/ios

**What it does:** AI-powered correlation engine that cross-references all collected evidence to find connections, contradictions, and hidden patterns.

**How to run:**
1. Forensics → for_149
2. Requires all previous modules to have run
3. Janus AI (Hailo-8) processes all Evidence
4. Correlation report with key findings generated

**Expected output:**
```
CORRELATION ENGINE: RUNNING
EVIDENCE ITEMS: 45,891
CORRELATIONS FOUND: 1,204
CONTRADICTIONS: 23
KEY FINDINGS: 45
SAVED: /Evidence/reports/correlation_report.json
```

**Note:** The correlation engine is the most powerful analysis tool — run it last after all data is collected.

---

## for_150 — Mission-Complete Forensic Package

**Platform:** android/ios

**What it does:** Final module — runs all remaining report generators, packages everything, and confirms the forensic collection is complete.

**How to run:**
1. Forensics → for_150
2. Confirms all critical modules have been run
3. Generates all report formats
4. Final package created and hash-verified

**Expected output:**
```
MISSION COMPLETE: RUNNING
MODULES COMPLETED: 149/150
REPORTS: ALL FORMATS GENERATED
FINAL ARCHIVE: CREATED
VERIFIED: ALL HASHES OK
STATUS: FORENSIC MISSION COMPLETE
```

**Note:** Run for_150 at the end of every forensic operation — it's the final quality check.

---

