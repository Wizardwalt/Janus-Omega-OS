package com.janus.omega

import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class SettingsActivity : AppCompatActivity() {

    private lateinit var prefs: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prefs = getSharedPreferences("janus_prefs", Context.MODE_PRIVATE)

        val layout = android.widget.LinearLayout(this)
        layout.orientation = android.widget.LinearLayout.VERTICAL
        layout.setPadding(40, 60, 40, 40)
        layout.setBackgroundColor(android.graphics.Color.parseColor("#08110B"))

        val title = TextView(this)
        title.text = "JANUS OMEGA — SETTINGS"
        title.setTextColor(android.graphics.Color.parseColor("#62FF8F"))
        title.textSize = 20f
        title.typeface = android.graphics.Typeface.MONOSPACE
        layout.addView(title)

        val label = TextView(this)
        label.text = "\nJanusOS Server URL\n(IP address of the machine running janus-web)"
        label.setTextColor(android.graphics.Color.parseColor("#D7FFE2"))
        label.textSize = 14f
        label.typeface = android.graphics.Typeface.MONOSPACE
        layout.addView(label)

        val urlInput = EditText(this)
        urlInput.setText(prefs.getString("server_url", "http://10.0.2.2:5000"))
        urlInput.setTextColor(android.graphics.Color.parseColor("#62FF8F"))
        urlInput.setBackgroundColor(android.graphics.Color.parseColor("#102018"))
        urlInput.typeface = android.graphics.Typeface.MONOSPACE
        urlInput.textSize = 16f
        urlInput.setPadding(16, 12, 16, 12)
        val lp = android.widget.LinearLayout.LayoutParams(
            android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
            android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
        )
        lp.topMargin = 16
        urlInput.layoutParams = lp
        layout.addView(urlInput)

        val hint = TextView(this)
        hint.text = "Emulator default: http://10.0.2.2:5000\nReal device: http://192.168.x.x:5000"
        hint.setTextColor(android.graphics.Color.parseColor("#62FF8F88".toLong(16).toInt()))
        hint.textSize = 12f
        hint.typeface = android.graphics.Typeface.MONOSPACE
        hint.setPadding(4, 8, 4, 0)
        layout.addView(hint)

        val saveBtn = Button(this)
        saveBtn.text = "SAVE"
        saveBtn.setTextColor(android.graphics.Color.parseColor("#08110B"))
        saveBtn.setBackgroundColor(android.graphics.Color.parseColor("#62FF8F"))
        saveBtn.typeface = android.graphics.Typeface.MONOSPACE
        val lp2 = android.widget.LinearLayout.LayoutParams(
            android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
            android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
        )
        lp2.topMargin = 24
        saveBtn.layoutParams = lp2
        layout.addView(saveBtn)

        val versionText = TextView(this)
        versionText.text = "\n\nJanus Omega v0.1.0\nTheme: Titan Green\nPlatform: Android"
        versionText.setTextColor(android.graphics.Color.parseColor("#62FF8F"))
        versionText.textSize = 12f
        versionText.typeface = android.graphics.Typeface.MONOSPACE
        layout.addView(versionText)

        saveBtn.setOnClickListener {
            val url = urlInput.text.toString().trim()
            if (url.startsWith("http://") || url.startsWith("https://")) {
                prefs.edit().putString("server_url", url).apply()
                Toast.makeText(this, "✓ Server URL saved", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "URL must start with http:// or https://", Toast.LENGTH_LONG).show()
            }
        }

        setContentView(layout)
    }
}
