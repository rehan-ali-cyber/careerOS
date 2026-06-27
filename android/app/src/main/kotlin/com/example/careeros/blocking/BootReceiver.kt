package com.example.careeros.blocking

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = context.getSharedPreferences("app_blocking_prefs", Context.MODE_PRIVATE)
            val hasBlockedApps = prefs.getString("blocked_apps", null)?.isNotEmpty() == true
            val hasSchedules = prefs.getString("blocking_schedules", null)?.isNotEmpty() == true
            if (hasBlockedApps || hasSchedules) AppMonitorService.start(context)
        }
    }
}
