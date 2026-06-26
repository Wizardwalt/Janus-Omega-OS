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
