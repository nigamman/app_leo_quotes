package com.nigamman.leoquotes

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationManagerCompat
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import com.google.firebase.FirebaseApp
import com.onesignal.OneSignal
import com.onesignal.debug.LogLevel
import java.util.concurrent.TimeUnit

val ONESIGNAL_APP_ID = ("8de30895-cf2a-46e9-b898-5782813f5be6")

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Firebase
        FirebaseApp.initializeApp(this)

        // Initialize OneSignal
        setupOneSignal()

        // Request Notification Permission (Android 13+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 1)
        }

        // Schedule WorkManager to update the widget periodically
        scheduleWidgetUpdates()
    }

    private fun scheduleWidgetUpdates() {
        val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
            240,
            TimeUnit.MINUTES
        ) // Minimum interval is 15 minutes
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED) // Update only when connected to the internet
                    .build()
            )
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "WidgetUpdateWork",
            ExistingPeriodicWorkPolicy.UPDATE, // Replace any existing work with the same name
            workRequest
        )
    }

    private fun setupOneSignal() {

        // OneSignal initialization
        OneSignal.initWithContext(this, ONESIGNAL_APP_ID)

        // Create Notification Channel (for Android 8.0+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "default", // This must match the channel ID in the OneSignal Dashboard
                "Default Channel",
                NotificationManager.IMPORTANCE_HIGH // High importance for heads-up notifications
            ).apply {
                description = "Default channel for notifications"
            }
            NotificationManagerCompat.from(this).createNotificationChannel(channel)
        }
    }
}
