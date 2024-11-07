# Keep all Firebase classes
-keep class com.google.firebase.** { *; }

# Firebase Realtime Database-specific rules
-keepnames class com.google.firebase.database.** { *; }
-dontwarn com.google.firebase.database.**

# Keep all WorkManager classes
-keep class androidx.work.** { *; }

# Keep all HomeWidget classes
-keep class es.antonborri.home_widget.** { *; }

# Keep your main activity and app widget provider
-keep class com.nigamman.leoquotes.MainActivity { *; }
-keep class com.nigamman.leoquotes.QuoteHomeWidgetProvider { *; }

# Keep OneSignal classes if using OneSignal
-keep class com.onesignal.** { *; }

# noinspection ShrinkerConfigInspection
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }

# Optional: If using Kotlin coroutines or other async processing, keep these classes
-keep class kotlinx.coroutines.** { *; }
