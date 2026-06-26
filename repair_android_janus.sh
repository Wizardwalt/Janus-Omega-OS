set -e

echo "== Repairing Android Janus launcher scaffold =="

mkdir -p android/app/src/main/java/com/janus/omega
mkdir -p android/app/src/main/res/layout
mkdir -p android/app/src/main/res/values
mkdir -p android/app/src/main/res/xml
mkdir -p android/app/src/main/res/drawable

cat > android/settings.gradle <<'EOT'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "JanusOmegaAndroid"
include(":app")
EOT

cat > android/build.gradle <<'EOT'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22"
    }
}
EOT

cat > android/gradle.properties <<'EOT'
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
EOT

cat > android/app/build.gradle <<'EOT'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.janus.omega'
    compileSdk 34

    defaultConfig {
        applicationId "com.janus.omega"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "0.1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
        debug {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    buildFeatures {
        viewBinding true
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.activity:activity-ktx:1.8.2'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
}
EOT

cat > android/app/src/main/AndroidManifest.xml <<'EOT'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.janus.omega">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:allowBackup="true"
        android:label="Janus Omega"
        android:supportsRtl="true"
        android:theme="@style/Theme.JanusOmega">

        <activity
            android:name=".SettingsActivity"
            android:exported="false" />

        <activity
            android:name=".DiagnosticsActivity"
            android:exported="false" />

        <activity
            android:name=".AssistantActivity"
            android:exported="false" />

        <activity
            android:name=".ModulesActivity"
            android:exported="false" />

        <activity
            android:name=".HomeActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>
</manifest>
EOT

cat > android/app/src/main/res/values/strings.xml <<'EOT'
<resources>
    <string name="app_name">Janus Omega</string>
</resources>
EOT

cat > android/app/src/main/res/values/colors.xml <<'EOT'
<resources>
    <color name="janus_bg">#08110B</color>
    <color name="janus_panel">#102018</color>
    <color name="janus_green">#62FF8F</color>
    <color name="janus_text">#D7FFE2</color>
    <color name="janus_accent">#9D00FF</color>
</resources>
EOT

cat > android/app/src/main/res/values/themes.xml <<'EOT'
<resources xmlns:tools="http://schemas.android.com/tools">
    <style name="Theme.JanusOmega" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/janus_green</item>
        <item name="colorPrimaryVariant">@color/janus_panel</item>
        <item name="colorSecondary">@color/janus_accent</item>
        <item name="android:windowBackground">@color/janus_bg</item>
        <item name="android:textColor">@color/janus_text</item>
    </style>
</resources>
EOT

cat > android/app/src/main/res/layout/activity_home.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/janus_bg">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            android:id="@+id/titleText"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="JANUS OMEGA"
            android:textColor="@color/janus_green"
            android:textSize="28sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/statusText"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Runtime status: unknown"
            android:textColor="@color/janus_text"
            android:textSize="16sp" />

        <Button
            android:id="@+id/modulesButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="20dp"
            android:text="Modules" />

        <Button
            android:id="@+id/assistantButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Assistant" />

        <Button
            android:id="@+id/diagnosticsButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Diagnostics" />

        <Button
            android:id="@+id/settingsButton"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="Settings" />
    </LinearLayout>
</ScrollView>
EOT

cat > android/app/src/main/res/layout/activity_simple_text.xml <<'EOT'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/janus_bg">

    <TextView
        android:id="@+id/contentText"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:padding="16dp"
        android:text="Janus"
        android:textColor="@color/janus_text"
        android:textSize="16sp" />
</ScrollView>
EOT

cat > android/app/src/main/java/com/janus/omega/RuntimeClient.kt <<'EOT'
package com.janus.omega

import java.net.HttpURLConnection
import java.net.URL

object RuntimeClient {
    private const val BASE_URL = "http://10.0.2.2:8080"

    fun get(path: String): String {
        return try {
            val url = URL(BASE_URL + path)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "GET"
            conn.connectTimeout = 2000
            conn.readTimeout = 2000
            conn.inputStream.bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            "Runtime unavailable: ${e.message}"
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/HomeActivity.kt <<'EOT'
package com.janus.omega

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class HomeActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)

        val statusText = findViewById<TextView>(R.id.statusText)
        val modulesButton = findViewById<Button>(R.id.modulesButton)
        val assistantButton = findViewById<Button>(R.id.assistantButton)
        val diagnosticsButton = findViewById<Button>(R.id.diagnosticsButton)
        val settingsButton = findViewById<Button>(R.id.settingsButton)

        modulesButton.setOnClickListener {
            startActivity(Intent(this, ModulesActivity::class.java))
        }

        assistantButton.setOnClickListener {
            startActivity(Intent(this, AssistantActivity::class.java))
        }

        diagnosticsButton.setOnClickListener {
            startActivity(Intent(this, DiagnosticsActivity::class.java))
        }

        settingsButton.setOnClickListener {
            startActivity(Intent(this, SettingsActivity::class.java))
        }

        thread {
            val result = RuntimeClient.get("/api/status")
            runOnUiThread {
                statusText.text = "Runtime status: $result"
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/ModulesActivity.kt <<'EOT'
package com.janus.omega

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.concurrent.thread

class ModulesActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_simple_text)

        val contentText = findViewById<TextView>(R.id.contentText)
        contentText.text = "Loading modules..."

        thread {
            val result = RuntimeClient.get("/api/modules")
            runOnUiThread {
                contentText.text = result
            }
        }
    }
}
EOT

cat > android/app/src/main/java/com/janus/omega/AssistantActivity.kt <<'EOT'
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
EOT

cat > android/app/src/main/java/com/janus/omega/DiagnosticsActivity.kt <<'EOT'
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
EOT

cat > android/app/src/main/java/com/janus/omega/SettingsActivity.kt <<'EOT'
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
EOT

cat > android/README.md <<'EOT'
# Janus Android Launcher

This Android project is a scaffold for the Titan-facing Janus launcher UI.

## Current Activities
- HomeActivity
- ModulesActivity
- AssistantActivity
- DiagnosticsActivity
- SettingsActivity

## Runtime Integration
The app currently expects the Janus runtime to be reachable at:

http://10.0.2.2:8080

This is the standard Android emulator mapping for host localhost.

## Next Steps
- add real JSON parsing
- add POST support for assistant chat
- add mode switching UI
- add evidence and notes screens
- add BootReceiver and foreground service
EOT

echo "== Android scaffold created =="

find android -maxdepth 4 -type f | sort

echo
echo "== If Gradle is available, try =="
echo "  cd android && ./gradlew tasks"
echo "or"
echo "  cd android && gradle tasks"
echo
echo "== If you are on Replit and Android SDK is missing, move this android/ folder to Android Studio later. =="
