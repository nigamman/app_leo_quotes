package com.nigamman.leoquotes

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetPlugin

class QuoteHomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.quote_widget_layout)

            // Fetch the saved quote from HomeWidget storage
            val quote = widgetData.getString("quote", "No Quote")
            Log.d("QuoteWidget", "Quote fetched: $quote") // Debug log to check the quote content

            // Update the widget layout with the fetched quote
            views.setTextViewText(R.id.widget_quote, quote)

            // Create an Intent to launch the MainActivity when the widget is clicked
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            // Create a PendingIntent to wrap the Intent
            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            val pendingIntent = PendingIntent.getActivity(context, 0, intent, pendingIntentFlags)

            // Set the PendingIntent on the widget's root view
            views.setOnClickPendingIntent(R.id.widget_layout_container, pendingIntent)

            // Apply the changes to the widget
            appWidgetManager.updateAppWidget(widgetId, views)
            Log.d("QuoteWidget", "Widget updated with quote: $quote") // Debug log for confirmation
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("QuoteWidget", "Device booted, widget needs to be updated")
            // Handle the boot completed event, rescheduling updates if necessary
        }
    }
}
