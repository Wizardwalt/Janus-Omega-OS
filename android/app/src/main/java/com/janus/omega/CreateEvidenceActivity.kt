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
