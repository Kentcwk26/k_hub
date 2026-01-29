package com.example.k_hub

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import es.antonborri.home_widget.HomeWidgetPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "widget_extractor"

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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "extractNoteWidget" -> {
                        val prefs = HomeWidgetPlugin.getData(this)
                        val widgetId = prefs.getInt(
                            "current_widget_id",
                            AppWidgetManager.INVALID_APPWIDGET_ID
                        )
                        val text = prefs.getString("note_text_$widgetId", "Empty note")
                        val imageFileName = prefs.getString("note_image_$widgetId", null)

                        if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                            NoteHomeWidget.updateNoteWidget(this, widgetId, text, imageFileName)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
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