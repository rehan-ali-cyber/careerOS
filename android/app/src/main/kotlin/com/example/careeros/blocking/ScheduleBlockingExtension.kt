package com.example.careeros.blocking

import android.content.Context
import android.os.Handler
import android.os.Looper

class ScheduleBlockingExtension(private val context: Context, private val manager: AppBlockingManager) {

    private val handler = Handler(Looper.getMainLooper())
    private var scheduleRunnable: Runnable? = null
    private val scheduleCheckIntervalMs = 30_000L
    private val schedules = mutableListOf<BlockSchedule>()

    fun loadAndApplySchedules() {
        schedules.clear()
        schedules.addAll(BlockingPreferences.getSchedules(context))
        applySchedules()
    }

    fun addSchedule(schedule: BlockSchedule) {
        schedules.add(schedule)
        BlockingPreferences.saveSchedules(context, schedules)
        applySchedules()
    }

    fun removeSchedule(id: String) {
        schedules.removeAll { it.id == id }
        BlockingPreferences.saveSchedules(context, schedules)
        applySchedules()
    }

    fun getSchedules(): List<BlockSchedule> = schedules.toList()

    private fun applySchedules() {
        for (schedule in schedules) {
            if (schedule.isActiveNow()) {
                manager.blockApp(schedule.packageName)
            } else {
                val hasActiveSchedule = schedules.any { it.packageName == schedule.packageName && it.id != schedule.id && it.isActiveNow() }
                if (!hasActiveSchedule) manager.unblockApp(schedule.packageName)
            }
        }
    }

    fun startScheduleMonitoring() {
        scheduleRunnable = object : Runnable {
            override fun run() { applySchedules(); handler.postDelayed(this, scheduleCheckIntervalMs) }
        }
        handler.post(scheduleRunnable!!)
    }

    fun stopScheduleMonitoring() {
        scheduleRunnable?.let { handler.removeCallbacks(it) }
        scheduleRunnable = null
    }
}
