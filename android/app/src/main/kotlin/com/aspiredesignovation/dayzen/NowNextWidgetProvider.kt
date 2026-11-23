package com.aspiredesignovation.dayzen

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.net.Uri
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * "Now / Next" home-screen widget (plan M-3.2).
 *
 * The app writes today's and tomorrow's active tasks plus the Rhythm curve
 * through home_widget (see lib/core/services/widget_service.dart). This
 * provider works out what is happening now and what comes next from the
 * clock when it draws, so it stays right with the app killed; Android
 * redraws it about hourly (updatePeriodMillis) and whenever the app saves.
 * Nothing here touches the network.
 */
class NowNextWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = Calendar.getInstance()
        val state = WidgetState.from(widgetData, now)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.now_next_widget)

            views.setTextViewText(
                R.id.widget_now_title,
                state.now?.title ?: context.getString(R.string.widget_nothing_now),
            )
            views.setTextViewText(
                R.id.widget_now_time,
                state.now?.let { "${fmt(it.start)}–${fmt(it.end)}" } ?: "",
            )
            views.setTextViewText(
                R.id.widget_next_title,
                state.next?.title ?: context.getString(R.string.widget_nothing_next),
            )
            views.setTextViewText(
                R.id.widget_next_time,
                state.next?.let { fmt(it.start) } ?: "",
            )
            views.setTextViewText(R.id.widget_window, state.windowLabel)

            state.rhythm?.let {
                views.setImageViewBitmap(
                    R.id.widget_tide,
                    drawTide(context, it, now.get(Calendar.HOUR_OF_DAY)),
                )
            }

            // Tapping opens the task in progress (or the next one), else the planner.
            val target = state.now ?: state.next
            val uri = if (target != null) {
                Uri.parse("dayzen://widget/task?id=${Uri.encode(target.id)}")
            } else {
                Uri.parse("dayzen://widget/planner")
            }
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun fmt(minute: Int): String {
        val m = ((minute % 1440) + 1440) % 1440
        val h = m / 60
        val suffix = if (h < 12) "am" else "pm"
        val display = if (h % 12 == 0) 12 else h % 12
        return if (m % 60 == 0) "$display $suffix" else "$display:%02d $suffix".format(m % 60)
    }

    /** A soft bar strip, 06:00–23:00, deeper where energy is higher. */
    private fun drawTide(context: Context, values: DoubleArray, currentHour: Int): Bitmap {
        val start = 6
        val end = 23
        val bars = end - start
        val w = 340
        val h = 40
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val accent = ContextCompat.getColor(context, R.color.widget_accent)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val gap = 3f
        val barW = (w - gap * (bars - 1)) / bars
        for (i in 0 until bars) {
            val hour = start + i
            val v = values.getOrElse(hour) { 0.0 }.coerceIn(0.05, 1.0)
            val alpha = if (hour == currentHour) 255 else (60 + 150 * v).toInt()
            paint.color = (accent and 0x00FFFFFF) or (alpha shl 24)
            val left = i * (barW + gap)
            val top = h - (h * v).toFloat()
            canvas.drawRoundRect(RectF(left, top, left + barW, h.toFloat()), 3f, 3f, paint)
        }
        return bmp
    }
}

private data class WidgetTask(val id: String, val title: String, val start: Int, val end: Int)

private data class WidgetState(
    val now: WidgetTask?,
    val next: WidgetTask?,
    val rhythm: DoubleArray?,
    val windowLabel: String,
) {
    companion object {
        fun from(data: SharedPreferences, now: Calendar): WidgetState {
            val fmt = SimpleDateFormat("yyyy-MM-dd", Locale.US)
            val today = fmt.format(now.time)
            val tomorrow = fmt.format((now.clone() as Calendar).apply {
                add(Calendar.DAY_OF_YEAR, 1)
            }.time)
            val minute = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)

            val days = parseDays(data.getString("dz_days", null))
            val todays = days[today].orEmpty()
            val current = todays.firstOrNull { t ->
                val end = if (t.end <= t.start) t.end + 1440 else t.end
                minute >= t.start && minute < end
            }
            val next = todays.firstOrNull { it.start > minute && it != current }
                ?: days[tomorrow]?.firstOrNull()

            val rhythm = data.getString("dz_rhythm", null)
                ?.split(",")
                ?.mapNotNull { it.toDoubleOrNull() }
                ?.takeIf { it.size == 24 }
                ?.toDoubleArray()

            return WidgetState(current, next, rhythm, data.getString("dz_window", "") ?: "")
        }

        private fun parseDays(raw: String?): Map<String, List<WidgetTask>> {
            if (raw == null) return emptyMap()
            return try {
                val obj = JSONObject(raw)
                obj.keys().asSequence().associateWith { day ->
                    val arr: JSONArray = obj.getJSONArray(day)
                    (0 until arr.length()).map { i ->
                        val t = arr.getJSONObject(i)
                        WidgetTask(
                            t.getString("id"),
                            t.getString("title"),
                            t.getInt("start"),
                            t.getInt("end"),
                        )
                    }.sortedBy { it.start }
                }
            } catch (e: Exception) {
                emptyMap()
            }
        }
    }
}
