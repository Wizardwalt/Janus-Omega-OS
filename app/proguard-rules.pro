# ProGuard configuration

# Keep class names
-keep public class * {
    public protected *;
}

# Keep all annotations
-keepattributes *Annotation*

# Keep all inner classes
-keep class *.* {
    <init>(...);
}

# Don't obfuscate some library classes
-keep class com.yourlibrary.** { *; }

# Other rules can be added as needed.