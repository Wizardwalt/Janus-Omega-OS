package com.janus.omega

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class DiagnosticsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_simple_text)

        val contentText = findViewById<TextView>(R.id.contentText)
        contentText.text = "Loading diagnostics..."

        thread {
            val status = RuntimeClient.get("/api/status")
            val audit = RuntimeClient.get("/api/audit")
            runOnUiThread {
                contentText.text = "STATUS\n$status\n\nAUDIT\n$audit"
            }
        }
    }
}
