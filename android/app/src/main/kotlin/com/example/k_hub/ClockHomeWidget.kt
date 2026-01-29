package com.example.k_hub

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

class ClockHomeWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(
                context.packageName,
                R.layout.widget_clock
            )

            val time = SimpleDateFormat("HH:mm", Locale.getDefault())
                .format(Date())

            views.setTextViewText(R.id.timeText, time)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}