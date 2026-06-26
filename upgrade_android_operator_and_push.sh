set -e

echo "== Upgrading Android launcher with operator mode, service scaffolding, and GitHub push =="

mkdir -p android/app/src/main/java/com/janus/omega
mkdir -p android/app/src/main/res/layout
mkdir -p android/app/src/main/res/xml

cat > android/app/src/main/AndroidManifest.xml <<'EOT'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.janus.omega">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:allowBackup="true"
        android:label="Janus Omega"
        android:supportsRtl="true"
        android:theme="@style/Theme.JanusOmega">

        <activity android:name=".NotesActivity" android:exported="false" />
        <activity android:name=".EvidenceActivity" android:exported="false" />
        <activity android:name=".OperatorActivity" android:exported="false" />
        <activity android:name=".SettingsActivity" android:exported="false" />
        <activity android:name=".DiagnosticsActivity" android:exported="false" />
        <activity android:name=".AssistantActivity" android:exported="false" />
        <activity android:name=".ModulesActivity" android:exported="false" />

        <activity
            android:name=".HomeActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <receiver
            android:name=".BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

        <service
            android:name=".JanusForegroundService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

    </application>
</manifest>
EOT

cat > android/app/src/main/res/layout/activity_home.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/janus_bg">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            android:id="@+id/titleText"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="JANUS OMEGA"
            android:textColor="@color/janus_green"
            android:textSize="28sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/statusText"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Runtime status: unknown"
            android:textColor="@color/janus_text"
            android:textSize="16sp" />

        <Button
            android:id="@+id/operatorButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="20dp"
            android:text="Enter Operator Mode" />

        <Button
            android:id="@+id/modulesButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Modules" />

        <Button
            android:id="@+id/assistantButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Assistant" />

        <Button
            android:id="@+id/diagnosticsButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Diagnostics" />

        <Button
            android:id="@+id/notesButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Notes" />

        <Button
            android:id="@+id/evidenceButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Evidence" />

        <Button
            android:id="@+id/settingsButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Settings" />
    </LinearLayout>
</ScrollView>
EOT

cat > android/app/src/main/res/layout/activity_operator.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/janus_bg">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            android:id="@+id/operatorTitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="OPERATOR MODE"
            android:textColor="@color/janus_green"
            android:textSize="26sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/operatorContent"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="Loading operator state..."
            android:textColor="@color/janus_text"
            android:textSize="16sp" />
    </LinearLayout>
</ScrollView>
EOT

cat > android/app/src/main/java/com/janus/omega/RuntimeClient.kt <<'EOT'
package com.janus.omega

import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

object RuntimeClient {
    private const val BASE_URL = "http://10.0.2.2:8080"

    fun get(path: String): String {
        return try {
            val url = URL(BASE_URL + path)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "GET"
            conn.connectTimeout = 2000
            conn.readTimeout = 2000
            conn.inputStream.bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            "Runtime unavailable: ${e.message}"
        }
    }

    fun post(path: String, body: String = ""): String {
        return try {
            val url = URL(BASE_URL + path)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.connectTimeout = 2000
            conn.readTimeout = 2000
            conn.doOutput = true
            if (body.isNotEmpty()) {
                conn.setRequestProperty("Content-Type", "application/json")
                OutputStreamWriter(conn.outputStream).use { it.write(body) }
            }
            conn.inputStream.bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            "Runtime unavailable: ${e.message}"
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/HomeActivity.kt <<'EOT'
package com.janus.omega

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class HomeActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)

        val statusText = findViewById<TextView>(R.id.statusText)
        val operatorButton = findViewById<Button>(R.id.operatorButton)
        val modulesButton = findViewById<Button>(R.id.modulesButton)
        val assistantButton = findViewById<Button>(R.id.assistantButton)
        val diagnosticsButton = findViewById<Button>(R.id.diagnosticsButton)
        val notesButton = findViewById<Button>(R.id.notesButton)
        val evidenceButton = findViewById<Button>(R.id.evidenceButton)
        val settingsButton = findViewById<Button>(R.id.settingsButton)

        startService(Intent(this, JanusForegroundService::class.java))

        operatorButton.setOnClickListener {
            startActivity(Intent(this, OperatorActivity::class.java))
        }

        modulesButton.setOnClickListener {
            startActivity(Intent(this, ModulesActivity::class.java))
        }

        assistantButton.setOnClickListener {
            startActivity(Intent(this, AssistantActivity::class.java))
        }

        diagnosticsButton.setOnClickListener {
            startActivity(Intent(this, DiagnosticsActivity::class.java))
        }

        notesButton.setOnClickListener {
            startActivity(Intent(this, NotesActivity::class.java))
        }

        evidenceButton.setOnClickListener {
            startActivity(Intent(this, EvidenceActivity::class.java))
        }

        settingsButton.setOnClickListener {
            startActivity(Intent(this, SettingsActivity::class.java))
        }

        thread {
            val result = RuntimeClient.get("/api/status")
            runOnUiThread {
                statusText.text = "Runtime status: $result"
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/OperatorActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class OperatorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_operator)

        val content = findViewById<TextView>(R.id.operatorContent)
        content.text = "Switching runtime mode..."

        thread {
            val modeResult = RuntimeClient.post("/api/mode/operator")
            val statusResult = RuntimeClient.get("/api/status")
            runOnUiThread {
                content.text = "MODE RESPONSE\n$modeResult\n\nSTATUS\n$statusResult"
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/NotesActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class NotesActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_simple_text)

        val contentText = findViewById<TextView>(R.id.contentText)
        contentText.text = "Loading notes..."

        thread {
            val result = RuntimeClient.get("/api/notes")
            runOnUiThread {
                contentText.text = result
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/EvidenceActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class EvidenceActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_simple_text)

        val contentText = findViewById<TextView>(R.id.contentText)
        contentText.text = "Loading evidence..."

        thread {
            val result = RuntimeClient.get("/api/evidence")
            runOnUiThread {
                contentText.text = result
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/BootReceiver.kt <<'EOT'
package com.janus.omega

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            context.startService(Intent(context, JanusForegroundService::class.java))
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/JanusForegroundService.kt <<'EOT'
package com.janus.omega

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

class JanusForegroundService : Service() {
    override fun onCreate() {
        super.onCreate()
        val channelId = "janus_runtime_channel"
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Janus Runtime",
                NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(channel)
        }

        val notification = Notification.Builder(this, channelId)
            .setContentTitle("Janus Omega")
            .setContentText("Runtime bridge active")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()

        startForeground(1001, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
EOT

cat > android/README.md <<'EOT'
# Janus Android Launcher

This Android project is a scaffold for the Titan-facing Janus launcher UI.

## Current Activities
- HomeActivity
- OperatorActivity
- ModulesActivity
- AssistantActivity
- DiagnosticsActivity
- NotesActivity
- EvidenceActivity
- SettingsActivity

## Services
- JanusForegroundService
- BootReceiver

## Runtime Integration
The app currently expects the Janus runtime to be reachable at:

http://10.0.2.2:8080

## Next Steps
- add real JSON parsing
- add assistant chat UI
- add module run buttons
- add evidence create UI
- add default-home launcher mode for Titan builds
EOT

echo "== Android operator scaffold updated =="

if [ -d .git ]; then
  echo "== Git repo detected =="
else
  echo "== Initializing git repo =="
  git init
  git branch -M main || true
fi

git add .

git commit -m "Add Android operator mode, service scaffolding, notes/evidence screens, and runtime bridge updates" || true

echo
echo "== Attempting GitHub push =="
git push || echo "Push failed. You may need to set remote/auth first."

echo
echo "== Done =="
echo "If push failed, run:"
echo "  git remote -v"
echo "  git status"
echo "  git push 2>&1 | tee git-push.log"
