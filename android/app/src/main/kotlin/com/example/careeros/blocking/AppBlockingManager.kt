package com.example.careeros.blocking

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.annotation.RequiresApi

class AppBlockingManager(private val context: Context) {

    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private val checkIntervalMs = 500L

    private val blockedApps = mutableSetOf<String>()
    private val blockedKeywords = mutableSetOf<String>()
    private var lastBlockedPackage: String? = null
    private var listener: BlockingEventListener? = null

    interface BlockingEventListener {
        fun onAppBlocked(packageName: String, appName: String)
        fun onInAppContentBlocked(packageName: String, keyword: String)
    }

    fun setBlockingEventListener(l: BlockingEventListener) { listener = l }

    fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun hasAccessibilityPermission(): Boolean {
        val enabledServices = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        return enabledServices.contains(context.packageName)
    }

    fun requestUsageStatsPermission() {
        context.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK })
    }

    fun requestAccessibilityPermission() {
        context.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK })
    }

    fun blockApp(packageName: String) { blockedApps.add(packageName); BlockingPreferences.saveBlockedApps(context, blockedApps) }
    fun unblockApp(packageName: String) { blockedApps.remove(packageName); lastBlockedPackage = null; BlockingPreferences.saveBlockedApps(context, blockedApps) }
    fun blockKeyword(keyword: String) { blockedKeywords.add(keyword.lowercase()); BlockingPreferences.saveBlockedKeywords(context, blockedKeywords) }
    fun unblockKeyword(keyword: String) { blockedKeywords.remove(keyword.lowercase()); BlockingPreferences.saveBlockedKeywords(context, blockedKeywords) }
    fun loadSavedRules() { blockedApps.addAll(BlockingPreferences.getBlockedApps(context)); blockedKeywords.addAll(BlockingPreferences.getBlockedKeywords(context)) }
    fun getBlockedApps(): Set<String> = blockedApps.toSet()
    fun getBlockedKeywords(): Set<String> = blockedKeywords.toSet()

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    fun getForegroundPackage(): String? {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(now - 3000, now)
        val event = UsageEvents.Event()
        var foreground: String? = null
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) foreground = event.packageName
        }
        return foreground
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    fun startMonitoring() {
        if (!hasUsageStatsPermission()) { requestUsageStatsPermission(); return }
        monitoringRunnable = object : Runnable {
            override fun run() { checkCurrentApp(); handler.postDelayed(this, checkIntervalMs) }
        }
        handler.post(monitoringRunnable!!)
    }

    fun stopMonitoring() { monitoringRunnable?.let { handler.removeCallbacks(it) }; monitoringRunnable = null }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    private fun checkCurrentApp() {
        val pkg = getForegroundPackage() ?: return
        if (pkg == context.packageName) return
        if (blockedApps.contains(pkg) && lastBlockedPackage != pkg) {
            lastBlockedPackage = pkg
            val appName = getAppName(pkg)
            listener?.onAppBlocked(pkg, appName)
            showBlockScreen(pkg, appName)
        } else if (!blockedApps.contains(pkg)) {
            lastBlockedPackage = null
        }
    }

    fun checkInAppContent(packageName: String, screenText: String) {
        if (!blockedApps.contains(packageName)) return
        val lower = screenText.lowercase()
        for (keyword in blockedKeywords) {
            if (lower.contains(keyword)) {
                listener?.onInAppContentBlocked(packageName, keyword)
                showBlockScreen(packageName, getAppName(packageName), keyword)
                break
            }
        }
    }

    private fun showBlockScreen(packageName: String, appName: String, keyword: String? = null) {
        val intent = Intent(context, BlockScreenActivity::class.java).apply {
            putExtra(BlockScreenActivity.EXTRA_PACKAGE_NAME, packageName)
            putExtra(BlockScreenActivity.EXTRA_APP_NAME, appName)
            keyword?.let { putExtra(BlockScreenActivity.EXTRA_KEYWORD, it) }
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        context.startActivity(intent)
    }

    fun getAppName(packageName: String): String {
        return try {
            val pm = context.packageManager
            pm.getApplicationLabel(pm.getApplicationInfo(packageName, 0)).toString()
        } catch (e: PackageManager.NameNotFoundException) { packageName }
    }

    fun getInstalledUserApps(): List<AppInfo> {
        val pm = context.packageManager
        return pm.getInstalledApplications(PackageManager.GET_META_DATA)
            .filter { pm.getLaunchIntentForPackage(it.packageName) != null }
            .map { AppInfo(it.packageName, pm.getApplicationLabel(it).toString(), pm.getApplicationIcon(it), blockedApps.contains(it.packageName)) }
            .sortedBy { it.appName }
    }
}
