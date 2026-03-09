package com.odysseyventures.startup_bite

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TermWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.term_widget_layout)

            val termKo = widgetData.getString("term_ko", "스타트업 한 입") ?: "스타트업 한 입"
            val termEn = widgetData.getString("term_en", "STARTUP BITE") ?: "STARTUP BITE"
            val definition = widgetData.getString("term_definition", "탭하여 앱에서 학습하기") ?: "탭하여 앱에서 학습하기"
            val dayLabel = widgetData.getString("day_label", "STARTUP BITE") ?: "STARTUP BITE"

            views.setTextViewText(R.id.widget_label, dayLabel)
            views.setTextViewText(R.id.widget_term_ko, termKo)
            views.setTextViewText(R.id.widget_term_en, termEn.uppercase())
            views.setTextViewText(R.id.widget_definition, definition)

            // Click container to open app
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            // "이해했어요" button → background callback
            val completeIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("startupbite://markcomplete")
            )
            views.setOnClickPendingIntent(R.id.btn_complete, completeIntent)

            // "다음 용어" button → background callback
            val nextIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("startupbite://nextterm")
            )
            views.setOnClickPendingIntent(R.id.btn_next, nextIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
