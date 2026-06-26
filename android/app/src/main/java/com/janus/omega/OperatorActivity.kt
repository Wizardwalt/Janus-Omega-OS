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
