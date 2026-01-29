package com.example.k_hub

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import es.antonborri.home_widget.HomeWidgetPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        saveWidgetId(intent)
        saveKWidgetMapping(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        saveWidgetId(intent)
        saveKWidgetMapping(intent)
    }

    private fun saveWidgetId(intent: Intent?) {
        val widgetId = intent?.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: return

        if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
            HomeWidgetPlugin.getData(this)
                .edit()
                .putInt("widgetId", widgetId)
                .apply()
        }
    }

    private fun handleWidgetIntent(intent: Intent?) {
        val appWidgetId = intent?.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: return

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return

        val prefs = HomeWidgetPlugin.getData(this)
        val pendingId = prefs.getString("pending_k_widget_id", null) ?: return

        // Map home screen widget ID -> Flutter widget ID
        prefs.edit()
            .putString("k_widget_mapping_$appWidgetId", pendingId)
            .remove("pending_k_widget_id")
            .apply()
    }

    private fun saveKWidgetMapping(intent: Intent?) {
        val appWidgetId = intent?.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: return

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return

        val prefs = HomeWidgetPlugin.getData(this)
        val kWidgetId = prefs.getString("pending_k_widget_id", null) ?: return

        prefs.edit()
            .putString("k_widget_mapping_$appWidgetId", kWidgetId)
            .remove("pending_k_widget_id")
            .apply()
    }
}