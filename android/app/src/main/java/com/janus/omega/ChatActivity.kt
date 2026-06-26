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
