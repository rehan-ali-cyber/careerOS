package com.example.careeros.blocking.data

import android.app.usage.UsageStatsManager
import android.content.Context
import android.util.Log
import com.example.careeros.blocking.BlockingPreferences
import java.util.Calendar

class AppBlockingRepository(private val context: Context, private val db: AppBlockingDatabase) {

    private val TAG = "AppBlockingRepo"

    suspend fun shouldBlock(packageName: String): Boolean {
        Log.d(TAG, "Checking block status for: $packageName")
        
        // 1. Check Daily Time Limits
        val limits = BlockingPreferences.getAppLimits(context)
        val limitMinutes = limits[packageName]
        if (limitMinutes != null && limitMinutes > 0) {
            val usageMinutes = getDailyUsageMinutes(packageName)
            Log.d(TAG, "Usage for $packageName: $usageMinutes min / Limit: $limitMinutes min")
            if (usageMinutes >= limitMinutes) {
                Log.w(TAG, "!!! LIMIT REACHED for $packageName !!!")
                return true
            }
        }

        // 2. Check Explicit Blocked List (Room)
        val app = db.blockedAppDao().getApp(packageName)
        if (app != null && !app.isWhitelisted) {
            Log.w(TAG, "!!! $packageName is explicitly blocked in Room DB !!!")
            return true
        }

        // 3. Check active Focus Sessions
        val nowMs = System.currentTimeMillis()
        val activeSession = db.focusSessionDao().getActiveSession(nowMs)
        if (activeSession != null) {
            Log.w(TAG, "!!! Focus Session is Active. Blocking $packageName !!!")
            return true
        }

        // 4. Check Schedules
        val schedules = db.scheduleDao().getSchedulesForApp(packageName)
        if (schedules.isNotEmpty()) {
            val cal = Calendar.getInstance()
            val currentDay = cal.get(Calendar.DAY_OF_WEEK).toString()
            val currentMinutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)

            val hasActiveSchedule = schedules.any { schedule ->
                val startMinutes = schedule.startHour * 60 + schedule.startMinute
                val endMinutes = schedule.endHour * 60 + schedule.endMinute
                val dayMatch = schedule.daysOfWeek.contains(currentDay)

                val isTimeMatch = if (startMinutes <= endMinutes) {
                    currentMinutes in startMinutes..endMinutes
                } else {
                    // Crosses midnight
                    currentMinutes >= startMinutes || currentMinutes <= endMinutes
                }
                dayMatch && isTimeMatch
            }
            if (hasActiveSchedule) {
                Log.w(TAG, "!!! Active Schedule detected for $packageName !!!")
                return true
            }
        }

        Log.d(TAG, "$packageName is allowed to run.")
        return false
    }

    private fun getDailyUsageMinutes(packageName: String): Int {
        return try {
            val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val calendar = Calendar.getInstance()
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            val startTime = calendar.timeInMillis
            val endTime = System.currentTimeMillis()

            val stats = usm.queryAndAggregateUsageStats(startTime, endTime)
            val usage = stats[packageName]
            if (usage != null) (usage.totalTimeInForeground / 60000).toInt() else 0
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching usage stats: ${e.message}")
            0
        }
    }

    suspend fun addBlockedApp(packageName: String, appName: String) {
        Log.i(TAG, "Adding $packageName to blocked apps in Room")
        db.blockedAppDao().insert(BlockedApp(packageName, appName))
    }

    suspend fun removeBlockedApp(packageName: String) {
        Log.i(TAG, "Removing $packageName from blocked apps in Room")
        val app = db.blockedAppDao().getApp(packageName)
        if (app != null) db.blockedAppDao().delete(app)
    }

    fun setAppLimit(packageName: String, minutes: Int) {
        Log.i(TAG, "Setting limit for $packageName: $minutes min")
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
        Log.i(TAG, "Syncing Guardian blocks: $blocks")
        BlockingPreferences.saveGuardianBlocks(context, blocks.toSet())
    }

    fun isGuardianEnabled(key: String): Boolean {
        return BlockingPreferences.getGuardianBlocks(context).contains(key)
    }

    suspend fun setSchedule(packageName: String, startH: Int, startM: Int, endH: Int, endM: Int, days: String) {
        Log.i(TAG, "Setting schedule for $packageName: $startH:$startM to $endH:$endM on $days")
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
