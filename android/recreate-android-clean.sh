#!/bin/bash
echo "=== Recreating Clean Android Project ==="

mkdir -p android/app/src/main/java/com/wizardwalt/janus
mkdir -p android/gradle/wrapper

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

# app/build.gradle (minimal Java)
cat > android/app/build.gradle << 'EOR'
plugins {
    id 'com.android.application'
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
}

dependencies {
    implementation 'androidx.core:core:1.13.1'
}
EOR

# AndroidManifest.xml
cat > android/app/src/main/AndroidManifest.xml << 'EOR'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Janus Ω OS">
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

# MainActivity.java (simple Pip-Boy style)
cat > android/app/src/main/java/com/wizardwalt/janus/MainActivity.java << 'EOR'
package com.wizardwalt.janus;

import android.os.Bundle;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        TextView tv = new TextView(this);
        tv.setText("JANUS Ω OS\nPip-Boy 3000 Online\n\nFLIP MODE");
        tv.setTextSize(24);
        tv.setTextColor(0xFF00FF41);
        setContentView(tv);
    }
}
EOR

# Gradle Wrapper
cat > android/gradle/wrapper/gradle-wrapper.properties << 'EOR'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOR

echo "✅ Clean Android project recreated."
echo "Next: Generate wrapper and build"
