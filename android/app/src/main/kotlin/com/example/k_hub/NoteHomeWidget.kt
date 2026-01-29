package com.example.k_hub

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class NoteHomeWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)

        for (widgetId in appWidgetIds) {

            prefs.edit()
                .putInt("current_widget_id", widgetId)
                .apply()

            val views = RemoteViews(
                context.packageName,
                R.layout.widget_note
            )

            val text = prefs.getString(
                "note_text_$widgetId",
                "Empty note"
            ) ?: "Empty note"

            views.setTextViewText(R.id.noteText, text)

            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                widgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.noteText, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}