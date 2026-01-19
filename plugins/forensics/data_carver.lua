-- Data Carver: WAL & Journal Analysis
-- Recovers deleted entries from SQLite databases

function execute()
    janus.log("SCANNING FOR SQLITE JOURNALS...")
    janus.log("TARGET: /data/com.android.providers.telephony/databases/mmssms.db-wal")
    
    janus.log("CARVING DELETED PAGES...")
    janus.log("RECOVERED: 14 Deleted SMS Messages")
    janus.log("RECOVERED: 3 Deleted Call Log Entries")
    
    janus.log("REPORT: Saved to /opt/janus/recovered_data.json")
end

execute()
