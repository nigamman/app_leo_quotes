package com.nigamman.leoquotes

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class WidgetUpdateWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
        val widgetComponent = ComponentName(applicationContext, QuoteWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)

        for (appWidgetId in appWidgetIds) {
            QuoteWidgetProvider.updateWidget(applicationContext, appWidgetManager, appWidgetId)
        }

        return Result.success()
    }
}
