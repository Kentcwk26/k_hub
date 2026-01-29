package com.example.k_hub

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context

object WidgetPinner {

    fun pinNoteWidget(context: Context) {
        val manager = AppWidgetManager.getInstance(context)

        if (manager.isRequestPinAppWidgetSupported) {
            val provider = ComponentName(
                context,
                NoteHomeWidget::class.java
            )

            manager.requestPinAppWidget(
                provider,
                null,
                null
            )
        }
    }
}