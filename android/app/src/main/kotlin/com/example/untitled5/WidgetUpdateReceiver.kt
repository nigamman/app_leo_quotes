package com.example.untitled5

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class WidgetUpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Trigger an update for the widget
        val updateIntent = Intent(context, MainActivity::class.java)
        updateIntent.putExtra("update", true)
        context.startService(updateIntent)
    }
}
