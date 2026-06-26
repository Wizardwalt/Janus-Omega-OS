package com.janus.omega

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class AssistantActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_simple_text)

        val contentText = findViewById<TextView>(R.id.contentText)
        contentText.text = "Loading assistant..."

        thread {
            val result = RuntimeClient.get("/api/assistant")
            runOnUiThread {
                contentText.text = result
            }
        }
    }
}
