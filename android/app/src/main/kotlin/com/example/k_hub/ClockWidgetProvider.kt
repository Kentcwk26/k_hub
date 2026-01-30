package com.example.k_hub

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ClockWidgetProvider : AppWidgetProvider() {

    companion object {
        private val handler = Handler(Looper.getMainLooper())
        private var runnable: Runnable? = null
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        startTicking(context, appWidgetManager, appWidgetIds)
    }

    override fun onDisabled(context: Context) {
        // Stop ticking when last widget is removed
        runnable?.let { handler.removeCallbacks(it) }
        runnable = null
    }

    private fun startTicking(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)

        val sdfTime = SimpleDateFormat("hh:mm:ss a", Locale.getDefault())
        val sdfDate = SimpleDateFormat("dd/MM/yyyy (EEEE)", Locale.getDefault())

        runnable?.let { handler.removeCallbacks(it) }

        runnable = object : Runnable {
            override fun run() {
                for (widgetId in appWidgetIds) {
                    val views = RemoteViews(
                        context.packageName,
                        R.layout.clock_widget
                    )

                    // ⏰ PER-SECOND TIME
                    views.setTextViewText(
                        R.id.clockTimeText,
                        sdfTime.format(Date()).uppercase()
                    )
                    views.setTextViewText(
                        R.id.clockDateText,
                        sdfDate.format(Date())
                    )

                    // 🖼️ IMAGE
                    val imagePath = prefs.getString("clock_image", "")

                    if (!imagePath.isNullOrEmpty()) {
                        val imgFile = File(imagePath)
                        if (imgFile.exists()) {
                            val options = BitmapFactory.Options().apply {
                                inPreferredConfig = Bitmap.Config.ARGB_8888
                            }
                            val bitmap = BitmapFactory.decodeFile(
                                imgFile.absolutePath,
                                options
                            )
                            views.setImageViewBitmap(
                                R.id.clockImage,
                                bitmap
                            )
                        } else {
                            views.setImageViewResource(
                                R.id.clockImage,
                                R.drawable.ic_placeholder
                            )
                        }
                    } else {
                        views.setImageViewResource(
                            R.id.clockImage,
                            R.drawable.ic_placeholder
                        )
                    }

                    appWidgetManager.updateAppWidget(widgetId, views)
                }

                // 🔁 TICK EVERY SECOND
                handler.postDelayed(this, 1000)
            }
        }

        handler.post(runnable!!)
    }
}