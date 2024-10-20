package com.example.untitled5

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.preference.PreferenceManager

//class QuoteWidgetProvider : AppWidgetProvider() {
//    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
//        super.onUpdate(context, appWidgetManager, appWidgetIds)
//
//        for (appWidgetId in appWidgetIds) {
//            updateAppWidget(context, appWidgetManager, appWidgetId)
//        }
//    }
//
//    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
//        // Retrieve the stored quote from SharedPreferences
//        val prefs: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
//        val quote = prefs.getString("selectedQuote", "No quote.")
//
//        // Update the widget layout with the quote
//        val views = RemoteViews(context.packageName, R.layout.quote_widget_layout)
//        views.setTextViewText(R.id.widget_quote, quote)
//
//        // Update the widget instance
//        appWidgetManager.updateAppWidget(appWidgetId, views)
//    }
//}
class QuoteWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)

        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        // Retrieve the stored quote from SharedPreferences
        val prefs: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
        val quote = prefs.getString("selectedQuote", "No quote available.")

        // Update the widget layout with the quote
        val views = RemoteViews(context.packageName, R.layout.quote_widget_layout)
        views.setTextViewText(R.id.widget_quote, quote)

        // Update the widget instance
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
