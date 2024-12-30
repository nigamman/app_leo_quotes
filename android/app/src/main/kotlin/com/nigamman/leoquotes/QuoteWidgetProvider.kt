package com.nigamman.leoquotes

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.google.firebase.database.FirebaseDatabase

class QuoteWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.widget_quote)
            views.setTextViewText(R.id.widget_quote, "Fetching quote...")

            // Add click functionality to open MainActivity
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quote, pendingIntent)

            fetchQuoteFromFirebase(context, appWidgetManager, views, appWidgetId)
        }

        private fun fetchQuoteFromFirebase(
            context: Context,
            appWidgetManager: AppWidgetManager,
            views: RemoteViews,
            appWidgetId: Int
        ) {
            val database = FirebaseDatabase.getInstance().reference.child("quotes")
            database.get().addOnSuccessListener { snapshot ->
                if (snapshot.exists() && snapshot.value is List<*>) {
                    val allCategories = snapshot.value as List<Map<String, Any>>
                    val allQuotes = mutableListOf<String>()

                    // Traverse categories to collect quotes
                    for (category in allCategories) {
                        val textMap = category["text"] as? Map<String, String>
                        if (textMap != null) {
                            allQuotes.addAll(textMap.values)
                        }
                    }

                    // Pick a random quote or fallback
                    val randomQuote = allQuotes.randomOrNull() ?: "Stay inspired!"
                    views.setTextViewText(R.id.widget_quote, randomQuote)
                } else {
                    views.setTextViewText(R.id.widget_quote, "No quotes found!")
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }.addOnFailureListener { e ->
                views.setTextViewText(R.id.widget_quote, "Error fetching quote")
                appWidgetManager.updateAppWidget(appWidgetId, views)
                e.printStackTrace()
            }
        }
    }
}
