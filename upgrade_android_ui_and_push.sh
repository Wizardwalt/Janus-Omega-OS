set -e

echo "== Upgrading Android UI with assistant chat, notes, evidence, and mode controls =="

mkdir -p android/app/src/main/res/layout
mkdir -p android/app/src/main/java/com/janus/omega

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

        <activity android:name=".ModeControlActivity" android:exported="false" />
        <activity android:name=".CreateEvidenceActivity" android:exported="false" />
        <activity android:name=".CreateNoteActivity" android:exported="false" />
        <activity android:name=".ChatActivity" android:exported="false" />
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

cat > android/app/src/main/res/layout/activity_simple_text.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/janus_bg">

    <TextView
        android:id="@+id/contentText"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:padding="16dp"
        android:text="Janus"
        android:textColor="@color/janus_text"
        android:textSize="16sp" />
</ScrollView>
EOT

cat > android/app/src/main/res/layout/activity_chat.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/janus_bg"
    android:padding="16dp">

    <EditText
        android:id="@+id/chatInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Ask Janus..."
        android:textColor="@color/janus_text"
        android:textColorHint="@color/janus_text" />

    <Button
        android:id="@+id/sendButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:text="Send" />

    <TextView
        android:id="@+id/chatOutput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text="Assistant output"
        android:textColor="@color/janus_text"
        android:textSize="16sp" />
</LinearLayout>
EOT

cat > android/app/src/main/res/layout/activity_create_note.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/janus_bg"
    android:padding="16dp">

    <EditText
        android:id="@+id/titleInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Note title"
        android:textColor="@color/janus_text"
        android:textColorHint="@color/janus_text" />

    <EditText
        android:id="@+id/bodyInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:hint="Note body"
        android:minLines="4"
        android:textColor="@color/janus_text"
        android:textColorHint="@color/janus_text" />

    <Button
        android:id="@+id/createNoteButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:text="Create Note" />

    <TextView
        android:id="@+id/noteResult"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:textColor="@color/janus_text" />
</LinearLayout>
EOT

cat > android/app/src/main/res/layout/activity_create_evidence.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/janus_bg"
    android:padding="16dp">

    <EditText
        android:id="@+id/labelInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Evidence label"
        android:textColor="@color/janus_text"
        android:textColorHint="@color/janus_text" />

    <EditText
        android:id="@+id/detailsInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:hint="Evidence details"
        android:minLines="4"
        android:textColor="@color/janus_text"
        android:textColorHint="@color/janus_text" />

    <EditText
        android:id="@+id/pathInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:hint="Attachment path (optional)"
        android:textColor="@color/janus_text"
        android:textColorHint="@color/janus_text" />

    <Button
        android:id="@+id/createEvidenceButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:text="Create Evidence" />

    <TextView
        android:id="@+id/evidenceResult"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:textColor="@color/janus_text" />
</LinearLayout>
EOT

cat > android/app/src/main/res/layout/activity_mode_control.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="@color/janus_bg"
    android:padding="16dp">

    <Button
        android:id="@+id/launcherModeButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Switch to Launcher Mode" />

    <Button
        android:id="@+id/operatorModeButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:text="Switch to Operator Mode" />

    <Button
        android:id="@+id/diagnosticsModeButton"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="12dp"
        android:text="Switch to Diagnostics Mode" />

    <TextView
        android:id="@+id/modeResult"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:textColor="@color/janus_text"
        android:text="Mode response" />
</LinearLayout>
EOT

cat > android/app/src/main/java/com/janus/omega/RuntimeClient.kt <<'EOT'
package com.janus.omega

import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

object RuntimeClient {
    private const val BASE_URL = "http://10.0.2.2:8080"

    fun pretty(raw: String): String {
        return raw
            .replace("{", "{\n")
            .replace("}", "\n}")
            .replace("\",\"", "\",\n\"")
            .replace("},", "},\n")
            .replace("],", "],\n")
    }

    fun get(path: String): String {
        return try {
            val url = URL(BASE_URL + path)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "GET"
            conn.connectTimeout = 3000
            conn.readTimeout = 3000
            conn.inputStream.bufferedReader().use { pretty(it.readText()) }
        } catch (e: Exception) {
            "Runtime unavailable: ${e.message}"
        }
    }

    fun post(path: String, body: String = ""): String {
        return try {
            val url = URL(BASE_URL + path)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.connectTimeout = 3000
            conn.readTimeout = 3000
            conn.doOutput = true
            if (body.isNotEmpty()) {
                conn.setRequestProperty("Content-Type", "application/json")
                OutputStreamWriter(conn.outputStream).use { it.write(body) }
            }
            conn.inputStream.bufferedReader().use { pretty(it.readText()) }
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
            startActivity(Intent(this, ChatActivity::class.java))
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
                statusText.text = "Runtime status:\n$result"
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/ChatActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class ChatActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_chat)

        val input = findViewById<EditText>(R.id.chatInput)
        val send = findViewById<Button>(R.id.sendButton)
        val output = findViewById<TextView>(R.id.chatOutput)

        send.setOnClickListener {
            val msg = input.text.toString().trim()
            if (msg.isEmpty()) {
                output.text = "Enter a message first."
                return@setOnClickListener
            }

            output.text = "Sending..."
            thread {
                val json = "{\"message\":\"" + msg.replace("\"", "\\\"") + "\"}"
                val result = RuntimeClient.post("/api/assistant/chat", json)
                runOnUiThread {
                    output.text = result
                }
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/CreateNoteActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class CreateNoteActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_create_note)

        val titleInput = findViewById<EditText>(R.id.titleInput)
        val bodyInput = findViewById<EditText>(R.id.bodyInput)
        val createButton = findViewById<Button>(R.id.createNoteButton)
        val resultView = findViewById<TextView>(R.id.noteResult)

        createButton.setOnClickListener {
            val title = titleInput.text.toString().trim()
            val body = bodyInput.text.toString().trim()

            if (title.isEmpty() || body.isEmpty()) {
                resultView.text = "Title and body are required."
                return@setOnClickListener
            }

            resultView.text = "Creating note..."
            thread {
                val json = "{\"title\":\"" + title.replace("\"", "\\\"") + "\",\"body\":\"" + body.replace("\"", "\\\"") + "\"}"
                val result = RuntimeClient.post("/api/notes/create", json)
                runOnUiThread {
                    resultView.text = result
                }
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/CreateEvidenceActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class CreateEvidenceActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_create_evidence)

        val labelInput = findViewById<EditText>(R.id.labelInput)
        val detailsInput = findViewById<EditText>(R.id.detailsInput)
        val pathInput = findViewById<EditText>(R.id.pathInput)
        val createButton = findViewById<Button>(R.id.createEvidenceButton)
        val resultView = findViewById<TextView>(R.id.evidenceResult)

        createButton.setOnClickListener {
            val label = labelInput.text.toString().trim()
            val details = detailsInput.text.toString().trim()
            val path = pathInput.text.toString().trim()

            if (label.isEmpty() || details.isEmpty()) {
                resultView.text = "Label and details are required."
                return@setOnClickListener
            }

            resultView.text = "Creating evidence..."
            thread {
                val json = "{\"label\":\"" + label.replace("\"", "\\\"") + "\",\"details\":\"" + details.replace("\"", "\\\"") + "\",\"attachment_path\":\"" + path.replace("\"", "\\\"") + "\"}"
                val result = RuntimeClient.post("/api/evidence/create", json)
                runOnUiThread {
                    resultView.text = result
                }
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/ModeControlActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class ModeControlActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mode_control)

        val launcherBtn = findViewById<Button>(R.id.launcherModeButton)
        val operatorBtn = findViewById<Button>(R.id.operatorModeButton)
        val diagnosticsBtn = findViewById<Button>(R.id.diagnosticsModeButton)
        val resultView = findViewById<TextView>(R.id.modeResult)

        fun switchMode(mode: String) {
            resultView.text = "Switching to $mode..."
            thread {
                val result = RuntimeClient.post("/api/mode/$mode")
                runOnUiThread {
                    resultView.text = result
                }
            }
        }

        launcherBtn.setOnClickListener { switchMode("launcher") }
        operatorBtn.setOnClickListener { switchMode("operator") }
        diagnosticsBtn.setOnClickListener { switchMode("diagnostics") }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/NotesActivity.kt <<'EOT'
package com.janus.omega

import android.content.Intent
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
                contentText.text = result + "\n\nOpen CreateNoteActivity from code/menu next."
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
                contentText.text = result + "\n\nOpen CreateEvidenceActivity from code/menu next."
            }
        }
    }
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
- ChatActivity
- DiagnosticsActivity
- NotesActivity
- CreateNoteActivity
- EvidenceActivity
- CreateEvidenceActivity
- ModeControlActivity
- SettingsActivity

## Services
- JanusForegroundService
- BootReceiver

## Runtime Integration
Expected runtime endpoint:

http://10.0.2.2:8080

## Working Android-side scaffold features
- runtime GET support
- runtime POST support
- assistant chat POST
- note create POST
- evidence create POST
- runtime mode switching POST

## Next Steps
- proper JSON parsing into models
- recycler/list-based UI
- button navigation to create screens
- default-home launcher mode
- Titan-style immersive operator UI
EOT

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"

git add android
git commit -m "Upgrade Android UI with assistant chat, create note/evidence, and mode control scaffolding" || true
git push -u origin "$CURRENT_BRANCH" || echo "Push failed. Check auth/remote."

echo
echo "== Done =="
echo "Pushed Android UI updates to branch: $CURRENT_BRANCH"
