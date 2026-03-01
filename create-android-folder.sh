#!/bin/bash
echo "=== Creating Full Working Android Folder ==="

mkdir -p android/app/src/main/kotlin/com/wizardwalt/janus
mkdir -p android/app/src/main/res

# settings.gradle
cat > android/settings.gradle << 'EOR'
rootProject.name = "JanusOmegaCompanion"
include ':app'
EOR

# build.gradle (root)
cat > android/build.gradle << 'EOR'
plugins {
    id 'com.android.application' version '8.7.0' apply false
}
EOR

# app/build.gradle
cat > android/app/build.gradle << 'EOR'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.wizardwalt.janus'
    compileSdk 35

    defaultConfig {
        applicationId "com.wizardwalt.janus"
        minSdk 24
        targetSdk 35
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
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
        compose true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = '1.5.14'
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.13.1'
    implementation platform('androidx.compose:compose-bom:2024.10.00')
    implementation 'androidx.compose.ui:ui'
    implementation 'androidx.compose.material3:material3'
    implementation 'androidx.activity:activity-compose:1.9.2'
}
EOR

# AndroidManifest.xml
cat > android/app/src/main/AndroidManifest.xml << 'EOR'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Janus Ω OS"
        android:theme="@style/Theme.JanusOmega">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOR

# MainActivity.kt (Pip-Boy UI)
cat > android/app/src/main/kotlin/com/wizardwalt/janus/MainActivity.kt << 'EOR'
package com.wizardwalt.janus

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            PipBoyTheme {
                JanusScreen()
            }
        }
    }
}

@Composable
fun JanusScreen() {
    var mode by remember { mutableStateOf("Omega Phone") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF001100))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("JANUS Ω OS", fontSize = 32.sp, color = Color(0xFF00FF41))
        Text("Pip-Boy 3000 Online", color = Color(0xFF00AA00), fontSize = 18.sp)

        Spacer(Modifier.height(32.dp))

        Text("Current Mode: $mode", color = Color(0xFF00FF41))

        Button(
            onClick = { mode = if (mode == "Omega Phone") "Janus Workstation" else "Omega Phone" },
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF003300))
        ) {
            Text("FLIP MODE", color = Color(0xFF00FF41))
        }

        Text("Scanlines active • Vault-Tec Systems", color = Color(0xFF00AA00), modifier = Modifier.padding(top = 32.dp))
    }
}

@Composable
fun PipBoyTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = darkColorScheme(primary = Color(0xFF00FF41), background = Color(0xFF001100)),
        content = content
    )
}
EOR

echo "✅ Full Android folder created with working Pip-Boy themed APK."
echo "Next: cd android && ./gradlew assembleDebug"
