package com.example.k_hub

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import androidx.core.content.FileProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

class NoteHomeWidget : AppWidgetProvider() {

    companion object {
        fun updateNoteWidget(context: Context, widgetId: Int, text: String?, imageFileName: String?) {
            val prefs = HomeWidgetPlugin.getData(context)
            prefs.edit().apply {
                if (text != null) putString("note_text_$widgetId", text)
                if (imageFileName != null) putString("note_image_$widgetId", imageFileName)
            }.apply()

            val views = RemoteViews(context.packageName, R.layout.widget_note)
            views.setTextViewText(R.id.noteText, text ?: "Empty note")

            if (imageFileName != null) {
                val file = File(context.filesDir, imageFileName)
                if (file.exists()) {
                    val uri = FileProvider.getUriForFile(
                        context,
                        "${context.packageName}.fileprovider",
                        file
                    )
                    views.setImageViewUri(R.id.noteImage, uri)

                    val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_HOME)
                    }
                    val resolveInfos = context.packageManager.queryIntentActivities(homeIntent, 0)
                    resolveInfos.forEach { resolveInfo ->
                        context.grantUriPermission(
                            resolveInfo.activityInfo.packageName,
                            uri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION
                        )
                    }
                }
            }

            val manager = AppWidgetManager.getInstance(context)
            manager.updateAppWidget(widgetId, views)
        }
    }

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

            val views = RemoteViews(context.packageName, R.layout.widget_note)
            val text = prefs.getString("note_text_$widgetId", "Empty note") ?: "Empty note"
            views.setTextViewText(R.id.noteText, text)

            val imageFileName = prefs.getString("note_image_$widgetId", null)

            if (imageFileName != null) {
                val file = File(context.filesDir, imageFileName)
                if (file.exists()) {
                    val uri = FileProvider.getUriForFile(
                        context,
                        "${context.packageName}.fileprovider",
                        file
                    )
                    views.setImageViewUri(R.id.noteImage, uri)

                    val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_HOME)
                    }
                    val resolveInfos = context.packageManager.queryIntentActivities(homeIntent, 0)
                    resolveInfos.forEach { resolveInfo ->
                        context.grantUriPermission(
                            resolveInfo.activityInfo.packageName,
                            uri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION
                        )
                    }
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}