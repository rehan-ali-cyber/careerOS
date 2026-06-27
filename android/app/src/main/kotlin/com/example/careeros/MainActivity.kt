package com.example.careeros

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.UserManager
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import com.example.careeros.blocking.AppBlockingManager
import com.example.careeros.blocking.AppMonitorService
import com.example.careeros.blocking.ScheduleBlockingExtension
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.careeros/lockdown"
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var isLockdownActive = false
    private var engine: FlutterEngine? = null
    
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringTask: Runnable? = null

    private lateinit var blockingManager: AppBlockingManager
    private lateinit var scheduleExt: ScheduleBlockingExtension

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.engine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockdown" -> {
                    isLockdownActive = true
                    startLockdown()
                    startMonitoringUnpin()
                    result.success(null)
                }
                "stopLockdown" -> {
                    isLockdownActive = false
                    stopLockdown()
                    stopMonitoringUnpin()
                    result.success(null)
                }
                "hijackAudio" -> {
                    hijackAudio()
                    result.success(null)
                }
                "releaseAudio" -> {
                    releaseAudio()
                    result.success(null)
                }
                "isDeviceOwner" -> {
                    result.success(isDeviceOwner())
                }
                // App Blocker Methods
                "getBlockedApps" -> {
                    result.success(blockingManager.getBlockedApps().toList())
                }
                "saveBlockedApps" -> {
                    val apps = call.arguments as List<String>
                    for (pkg in apps) blockingManager.blockApp(pkg)
                    // Also need to handle removal
                    val current = blockingManager.getBlockedApps()
                    for (pkg in current) if (!apps.contains(pkg)) blockingManager.unblockApp(pkg)
                    result.success(null)
                }
                "getBlockedKeywords" -> {
                    result.success(blockingManager.getBlockedKeywords().toList())
                }
                "saveBlockedKeywords" -> {
                    val keywords = call.arguments as List<String>
                    for (k in keywords) blockingManager.blockKeyword(k)
                    val current = blockingManager.getBlockedKeywords()
                    for (k in current) if (!keywords.contains(k)) blockingManager.unblockKeyword(k)
                    result.success(null)
                }
                "getInstalledApps" -> {
                    val apps = blockingManager.getInstalledUserApps().map { 
                        mapOf("packageName" to it.packageName, "appName" to it.appName)
                    }
                    result.success(apps)
                }
                "getAppLimits" -> {
                    result.success(blockingManager.getAppLimits())
                }
                "setAppLimit" -> {
                    val pkg = call.argument<String>("packageName")
                    val mins = call.argument<Int>("minutes")
                    if (pkg != null && mins != null) {
                        blockingManager.setAppLimit(pkg, mins)
                    }
                    result.success(null)
                }
                "getGuardianBlocks" -> {
                    result.success(blockingManager.getGuardianBlocks())
                }
                "saveGuardianBlocks" -> {
                    val blocks = call.arguments as List<String>
                    blockingManager.syncGuardianBlocks(blocks)
                    result.success(null)
                }
                "getDailyUsage" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg != null) {
                        result.success(blockingManager.getDailyUsageMinutes(pkg))
                    } else {
                        result.error("INVALID_ARG", "Package name required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        
        blockingManager = AppBlockingManager.getInstance(this)
        scheduleExt = ScheduleBlockingExtension(this, blockingManager)
        scheduleExt.loadAndApplySchedules()

        if (blockingManager.hasUsageStatsPermission()) {
            AppMonitorService.start(this)
            scheduleExt.startScheduleMonitoring()
        } else {
            blockingManager.requestUsageStatsPermission()
        }

        if (!blockingManager.hasAccessibilityPermission()) {
            blockingManager.requestAccessibilityPermission()
        }
    }

    override fun onResume() {
        super.onResume()
        if (::blockingManager.isInitialized && ::scheduleExt.isInitialized) {
            if (blockingManager.hasUsageStatsPermission() && !AppMonitorService.isRunning) {
                AppMonitorService.start(this)
                scheduleExt.startScheduleMonitoring()
            }
        }
    }

    override fun onDestroy() {
        if (::scheduleExt.isInitialized) {
            scheduleExt.stopScheduleMonitoring()
        }
        super.onDestroy()
    }

    private fun startLockdown() {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminName = ComponentName(this, DeviceAdmin::class.java)

        if (dpm.isDeviceOwnerApp(packageName)) {
            dpm.setLockTaskPackages(adminName, arrayOf(packageName))
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                dpm.setLockTaskFeatures(adminName, DevicePolicyManager.LOCK_TASK_FEATURE_NONE)
            }
        }
        
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        applyImmersiveMode()
        
        try {
            startLockTask()
        } catch (e: Exception) {}
    }

    private fun stopLockdown() {
        try {
            stopLockTask()
        } catch (e: Exception) {}
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun startMonitoringUnpin() {
        monitoringTask = object : Runnable {
            override fun run() {
                if (isLockdownActive) {
                    if (!isInLockTaskMode()) {
                        // User unpinned the app!
                        notifyFlutterUnpinned()
                        isLockdownActive = false // Deactivate locally to stop double-triggering
                    } else {
                        handler.postDelayed(this, 1000)
                    }
                }
            }
        }
        handler.postDelayed(monitoringTask!!, 2000) // Start checking after 2 seconds
    }

    private fun stopMonitoringUnpin() {
        monitoringTask?.let { handler.removeCallbacks(it) }
        monitoringTask = null
    }

    private fun isInLockTaskMode(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
        } else {
            @Suppress("DEPRECATION")
            activityManager.isInLockTaskMode
        }
    }

    private fun notifyFlutterUnpinned() {
        engine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL).invokeMethod("onUnpinned", null)
        }
    }

    private fun applyImmersiveMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or android.view.View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or android.view.View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or android.view.View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or android.view.View.SYSTEM_UI_FLAG_FULLSCREEN
            )
        }
    }

    private fun hijackAudio() {
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build())
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener { }
                .build()
            audioManager?.requestAudioFocus(audioFocusRequest!!)
        } else {
            @Suppress("DEPRECATION")
            audioManager?.requestAudioFocus({ }, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN)
        }
    }

    private fun releaseAudio() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus { }
        }
    }

    private fun isDeviceOwner(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        return dpm.isDeviceOwnerApp(packageName)
    }
}
