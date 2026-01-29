package com.example.k_hub

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

class IdolHomeWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)

        for (widgetId in appWidgetIds) {

            val imagePath = prefs.getString("wallpaper_image_path_$widgetId", null)

            val views = RemoteViews(
                context.packageName,
                R.layout.idol_home_widget
            )

            if (imagePath != null) {
                val file = File(imagePath)

                if (file.exists()) {
                    val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                    views.setViewVisibility(R.id.widget_image, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_overlay_text, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_empty_state, View.GONE)
                } else {
                    showEmptyState(views)
                }
            } else {
                showEmptyState(views)
            }

            val intent = Intent(context, MainActivity::class.java).apply {
                putExtra("open", "wallpaper_creator")
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                widgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(
                R.id.widget_create_button,
                pendingIntent
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun showEmptyState(views: RemoteViews) {
        views.setViewVisibility(R.id.widget_image, View.GONE)
        views.setViewVisibility(R.id.widget_overlay_text, View.GONE)
        views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
    }
}