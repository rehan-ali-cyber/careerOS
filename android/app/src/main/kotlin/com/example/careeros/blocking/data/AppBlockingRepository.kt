package com.example.careeros.blocking.data

import android.content.Context
import com.example.careeros.blocking.BlockingPreferences
import java.util.Calendar

class AppBlockingRepository(private val context: Context, private val db: AppBlockingDatabase) {

    suspend fun shouldBlock(packageName: String): Boolean {
        // 1. Check if app is explicitly blocked
        val app = db.blockedAppDao().getApp(packageName) ?: return false
        if (app.isWhitelisted) return false

        // 2. Check for active Focus Session
        val nowMs = System.currentTimeMillis()
        val activeSession = db.focusSessionDao().getActiveSession(nowMs)
        if (activeSession != null) {
            return true
        }

        // 3. Check for active Schedules
        val schedules = db.scheduleDao().getSchedulesForApp(packageName)
        if (schedules.isEmpty()) return false

        val cal = Calendar.getInstance()
        val currentDay = cal.get(Calendar.DAY_OF_WEEK).toString()
        val currentMinutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)

        return schedules.any { schedule ->
            val startMinutes = schedule.startHour * 60 + schedule.startMinute
            val endMinutes = schedule.endHour * 60 + schedule.endMinute
            val dayMatch = schedule.daysOfWeek.contains(currentDay)

            val isTimeMatch = if (startMinutes <= endMinutes) {
                currentMinutes in startMinutes..endMinutes
            } else {
                currentMinutes >= startMinutes || currentMinutes <= endMinutes
            }

            dayMatch && isTimeMatch
        }
    }

    suspend fun addBlockedApp(packageName: String, appName: String) {
        db.blockedAppDao().insert(BlockedApp(packageName, appName))
    }

    suspend fun removeBlockedApp(packageName: String) {
        val app = db.blockedAppDao().getApp(packageName)
        if (app != null) db.blockedAppDao().delete(app)
    }

    fun setAppLimit(packageName: String, minutes: Int) {
        val limits = BlockingPreferences.getAppLimits(context).toMutableMap()
        if (minutes <= 0) limits.remove(packageName) else limits[packageName] = minutes
        BlockingPreferences.saveAppLimits(context, limits)
    }

    fun getAppLimits(): Map<String, Int> {
        return BlockingPreferences.getAppLimits(context)
    }

    fun getGuardianBlocks(): List<String> {
        return BlockingPreferences.getGuardianBlocks(context).toList()
    }

    fun syncGuardianBlocks(blocks: List<String>) {
        BlockingPreferences.saveGuardianBlocks(context, blocks.toSet())
    }

    suspend fun setSchedule(packageName: String, startH: Int, startM: Int, endH: Int, endM: Int, days: String) {
        db.scheduleDao().insert(BlockSchedule(
            packageName = packageName,
            startHour = startH,
            startMinute = startM,
            endHour = endH,
            endMinute = endM,
            daysOfWeek = days
        ))
    }
}
