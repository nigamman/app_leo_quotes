# Firebase and Google Play Services
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# WorkManager
-keep class androidx.work.** { *; }

# HomeWidget
-keep class es.antonborri.home_widget.** { *; }
-dontwarn es.antonborri.home_widget.**

-keep class com.nigamman.leoquotes.** { *; }

# Main activity and app widget provider
-keep class com.nigamman.leoquotes.MainActivity { *; }
-keep class com.nigamman.leoquotes.QuoteWidgetProvider { *; }

# OneSignal (if using)
-keep class com.onesignal.** { *; }
-keep class com.onesignal.Notification* { *; }

# SharedPreferences
# Keep SharedPreferences-related classes
-keep class android.content.SharedPreferences** { *; }

# Kotlin coroutines (if using async processing)
-keep class kotlinx.coroutines.** { *; }
-keepclassmembers class kotlinx.coroutines.** { *; }

# Keep annotations and method signatures
-keepattributes Signature
-keepattributes *Annotation*

-keep class **AppWidgetProvider { *; }

-keep class androidx.preference.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class dev.fluttercommunity.plus.sharedpreferences.** { *; }