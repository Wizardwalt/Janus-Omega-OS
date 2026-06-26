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
