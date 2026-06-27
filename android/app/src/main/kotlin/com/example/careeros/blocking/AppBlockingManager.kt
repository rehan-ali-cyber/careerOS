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
import android.util.Log
import androidx.annotation.RequiresApi

class AppBlockingManager private constructor(private val context: Context) {

    companion object {
        private const val TAG = "AppBlockingManager"
        @Volatile
        private var INSTANCE: AppBlockingManager? = null

        fun getInstance(context: Context): AppBlockingManager {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: AppBlockingManager(context).also { INSTANCE = it }
            }
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private val checkIntervalMs = 500L

    private val blockedApps = mutableSetOf<String>()
    private val blockedKeywords = mutableSetOf<String>()
    private val appLimits = mutableMapOf<String, Int>() // Package to Limit in Minutes
    private var lastBlockedPackage: String? = null
    private var listener: BlockingEventListener? = null

    init {
        loadSavedRules()
    }

    interface BlockingEventListener {
        fun onAppBlocked(packageName: String, appName: String)
        fun onInAppContentBlocked(packageName: String, keyword: String)
    }

    fun setBlockingEventListener(l: BlockingEventListener?) { listener = l }

    fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
        }
        val granted = mode == AppOpsManager.MODE_ALLOWED
        Log.d(TAG, "Usage Stats Permission: $granted")
        return granted
    }

    fun hasAccessibilityPermission(): Boolean {
        val enabledServices = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: ""
        val granted = enabledServices.contains(context.packageName)
        Log.d(TAG, "Accessibility Permission: $granted")
        return granted
    }

    fun requestUsageStatsPermission() {
        Log.i(TAG, "Requesting Usage Stats Permission")
        context.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply { 
            flags = Intent.FLAG_ACTIVITY_NEW_TASK 
        })
    }

    fun requestAccessibilityPermission() {
        Log.i(TAG, "Requesting Accessibility Permission")
        context.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply { 
            flags = Intent.FLAG_ACTIVITY_NEW_TASK 
        })
    }

    fun blockApp(packageName: String) { 
        Log.i(TAG, "Blocking app: $packageName")
        blockedApps.add(packageName)
        BlockingPreferences.saveBlockedApps(context, blockedApps) 
    }
    
    fun unblockApp(packageName: String) { 
        Log.i(TAG, "Unblocking app: $packageName")
        blockedApps.remove(packageName)
        lastBlockedPackage = null
        BlockingPreferences.saveBlockedApps(context, blockedApps) 
    }
    
    fun setAppLimit(packageName: String, minutes: Int) {
        if (minutes <= 0) {
            appLimits.remove(packageName)
        } else {
            appLimits[packageName] = minutes
        }
        BlockingPreferences.saveAppLimits(context, appLimits)
    }

    fun getAppLimits(): Map<String, Int> = appLimits.toMap()

    fun blockKeyword(keyword: String) { 
        val k = keyword.lowercase()
        Log.i(TAG, "Adding keyword: $k")
        blockedKeywords.add(k)
        BlockingPreferences.saveBlockedKeywords(context, blockedKeywords) 
    }
    
    fun unblockKeyword(keyword: String) { 
        val k = keyword.lowercase()
        Log.i(TAG, "Removing keyword: $k")
        blockedKeywords.remove(k)
        BlockingPreferences.saveBlockedKeywords(context, blockedKeywords) 
    }
    
    fun loadSavedRules() { 
        val apps = BlockingPreferences.getBlockedApps(context)
        val keywords = BlockingPreferences.getBlockedKeywords(context)
        val limits = BlockingPreferences.getAppLimits(context)
        blockedApps.clear()
        blockedApps.addAll(apps)
        blockedKeywords.clear()
        blockedKeywords.addAll(keywords)
        appLimits.clear()
        appLimits.putAll(limits)
        Log.d(TAG, "Rules Loaded: ${blockedApps.size} apps, ${blockedKeywords.size} keywords, ${appLimits.size} limits")
    }
    
    fun getBlockedApps(): Set<String> = blockedApps.toSet()
    fun getBlockedKeywords(): Set<String> = blockedKeywords.toSet()

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    fun getForegroundPackage(): String? {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(now - 10000, now) 
        val event = UsageEvents.Event()
        var foreground: String? = null
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                foreground = event.packageName
            }
        }
        return foreground
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    fun startMonitoring() {
        if (monitoringRunnable != null) return
        Log.d(TAG, "Starting app monitoring loop...")
        
        monitoringRunnable = object : Runnable {
            override fun run() { 
                checkCurrentApp()
                handler.postDelayed(this, checkIntervalMs) 
            }
        }
        handler.post(monitoringRunnable!!)
    }

    fun stopMonitoring() { 
        Log.d(TAG, "Stopping app monitoring loop.")
        monitoringRunnable?.let { handler.removeCallbacks(it) }
        monitoringRunnable = null 
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    private fun checkCurrentApp() {
        val pkg = getForegroundPackage() ?: return
        if (pkg == context.packageName) return
        
        // 1. Check direct blocking
        if (blockedApps.contains(pkg)) {
            if (lastBlockedPackage != pkg) {
                Log.w(TAG, "!!! BLOCKING APP: $pkg")
                lastBlockedPackage = pkg
                val appName = getAppName(pkg)
                listener?.onAppBlocked(pkg, appName)
                showBlockScreen(pkg, appName)
            }
            return
        }

        // 2. Check time limits
        val limit = appLimits[pkg]
        if (limit != null) {
            val usageMinutes = getDailyUsageMinutes(pkg)
            if (usageMinutes >= limit) {
                if (lastBlockedPackage != pkg) {
                    Log.w(TAG, "!!! BLOCKING APP (Limit Reached): $pkg ($usageMinutes >= $limit)")
                    lastBlockedPackage = pkg
                    val appName = getAppName(pkg)
                    listener?.onAppBlocked(pkg, appName)
                    showBlockScreen(pkg, appName, "Daily time limit reached ($limit min)")
                }
                return
            }
        }

        lastBlockedPackage = null
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    fun getDailyUsageMinutes(packageName: String): Int {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = java.util.Calendar.getInstance()
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
        calendar.set(java.util.Calendar.MINUTE, 0)
        calendar.set(java.util.Calendar.SECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usm.queryAndAggregateUsageStats(startTime, endTime)
        val usage = stats[packageName]
        return if (usage != null) (usage.totalTimeInForeground / 60000).toInt() else 0
    }

    fun checkInAppContent(packageName: String, screenText: String) {
        if (packageName == context.packageName) return
        
        val lower = screenText.lowercase()
        for (keyword in blockedKeywords) {
            if (lower.contains(keyword)) {
                Log.w(TAG, "!!! BLOCKING CONTENT in $packageName: keyword '$keyword' found")
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
