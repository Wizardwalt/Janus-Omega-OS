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
