package com.janus.omega

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class SettingsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_simple_text)

        val contentText = findViewById<TextView>(R.id.contentText)
        contentText.text = """
            Janus Omega Settings
            
            - Runtime URL: http://10.0.2.2:8080
            - Theme: Titan Green
            - Mode switching: planned
            - Launcher integration: scaffolded
        """.trimIndent()
    }
}
