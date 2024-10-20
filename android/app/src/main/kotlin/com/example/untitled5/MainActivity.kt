package com.example.untitled5

//import android.appwidget.AppWidgetManager
//import android.content.ComponentName
//import android.content.Intent
//import android.content.SharedPreferences
//import android.preference.PreferenceManager
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity : FlutterActivity() {
//    private val CHANNEL = "com.example.untitled5/appwidget"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "updateWidget") {
//                val quote = call.argument<String>("quote") ?: "No quote available."
//                saveQuoteToPreferences(quote)
//                updateWidget()
//                result.success(null)
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
//
//    // Save the quote to SharedPreferences
//    private fun saveQuoteToPreferences(quote: String) {
//        val prefs: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
//        val editor = prefs.edit()
//        editor.putString("selectedQuote", quote)
//        editor.apply()
//    }
//
//    // Update the widget by broadcasting an update intent
//    private fun updateWidget() {
//        val intent = Intent(this, QuoteWidgetProvider::class.java)
//        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
//
//        val ids = AppWidgetManager.getInstance(application)
//            .getAppWidgetIds(ComponentName(application, QuoteWidgetProvider::class.java))
//
//        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
//        sendBroadcast(intent)
//    }
//}

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.content.SharedPreferences
import android.preference.PreferenceManager
import android.os.Bundle
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.untitled5/appwidget"
    private val UPDATE_INTERVAL = (6 * 60 * 60 * 1000).toLong() // 6 hours in milliseconds

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                val quote = call.argument<String>("quote") ?: "No quote available."
                saveQuoteToPreferences(quote)
                updateWidget()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Set up AlarmManager to update the widget every 6 hours
        setupAlarm()
    }

    // Function to set up the alarm for widget updates
    private fun setupAlarm() {
        val intent = Intent(this, WidgetUpdateReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE // Ensure FLAG_IMMUTABLE for API 31+
        )
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setInexactRepeating(
            AlarmManager.RTC_WAKEUP,
            System.currentTimeMillis(),
            UPDATE_INTERVAL,
            pendingIntent
        )
    }

    // Save the quote to SharedPreferences
    private fun saveQuoteToPreferences(quote: String) {
        val prefs: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        val editor = prefs.edit()
        editor.putString("selectedQuote", quote)
        editor.apply()
    }

    // Update the widget by broadcasting an update intent
    private fun updateWidget() {
        val intent = Intent(this, QuoteWidgetProvider::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE

        val ids = AppWidgetManager.getInstance(application)
            .getAppWidgetIds(ComponentName(application, QuoteWidgetProvider::class.java))

        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        sendBroadcast(intent)
    }
}

