package com.example.careeros.blocking

import android.graphics.drawable.Drawable

data class AppInfo(
    val packageName: String,
    val appName: String,
    val icon: Drawable,
    val isBlocked: Boolean
)

data class BlockSchedule(
    val id: String,
    val packageName: String,
    val startHour: Int,
    val startMinute: Int,
    val endHour: Int,
    val endMinute: Int,
    val daysOfWeek: Set<Int> = emptySet(),
    val isEnabled: Boolean = true
) {
    fun isActiveNow(): Boolean {
        if (!isEnabled) return false
        val cal = java.util.Calendar.getInstance()
        val dayOfWeek = cal.get(java.util.Calendar.DAY_OF_WEEK)
        if (daysOfWeek.isNotEmpty() && !daysOfWeek.contains(dayOfWeek)) return false
        val nowMinutes = cal.get(java.util.Calendar.HOUR_OF_DAY) * 60 + cal.get(java.util.Calendar.MINUTE)
        val startMinutes = startHour * 60 + startMinute
        val endMinutes = endHour * 60 + endMinute
        return if (startMinutes <= endMinutes) {
            nowMinutes in startMinutes..endMinutes
        } else {
            nowMinutes >= startMinutes || nowMinutes <= endMinutes
        }
    }
}

data class BlockingEvent(
    val packageName: String,
    val appName: String,
    val keyword: String?,
    val timestampMs: Long = System.currentTimeMillis(),
    val isInAppBlock: Boolean = keyword != null
)
