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
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import com.example.careeros.blocking.BlockScreenActivity
import com.example.careeros.blocking.data.AppBlockingDatabase
import com.example.careeros.blocking.data.AppBlockingRepository
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.careeros/lockdown"
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private lateinit var repository: AppBlockingRepository
    
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var isLockdownActive = false
    private var engine: FlutterEngine? = null
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringTask: Runnable? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val db = AppBlockingDatabase.getInstance(this)
        repository = AppBlockingRepository(this, db)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.engine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Professional App Blocking Methods
                "addBlockedApp" -> {
                    val pkg = call.argument<String>("packageName") ?: ""
                    val name = call.argument<String>("appName") ?: ""
                    mainScope.launch(Dispatchers.IO) {
                        repository.addBlockedApp(pkg, name)
                        launch(Dispatchers.Main) { result.success(null) }
                    }
                }
                "removeBlockedApp" -> {
                    val pkg = call.argument<String>("packageName") ?: ""
                    mainScope.launch(Dispatchers.IO) {
                        repository.removeBlockedApp(pkg)
                        launch(Dispatchers.Main) { result.success(null) }
                    }
                }
                "setSchedule" -> {
                    val pkg = call.argument<String>("packageName") ?: ""
                    val startH = call.argument<Int>("startHour") ?: 0
                    val startM = call.argument<Int>("startMinute") ?: 0
                    val endH = call.argument<Int>("endHour") ?: 0
                    val endM = call.argument<Int>("endMinute") ?: 0
                    val days = call.argument<String>("daysOfWeek") ?: ""
                    mainScope.launch(Dispatchers.IO) {
                        repository.setSchedule(pkg, startH, startM, endH, endM, days)
                        launch(Dispatchers.Main) { result.success(null) }
                    }
                }
                "getAppLimits" -> {
                    mainScope.launch(Dispatchers.IO) {
                        val limits = repository.getAppLimits()
                        launch(Dispatchers.Main) { result.success(limits) }
                    }
                }
                "setAppLimit" -> {
                    val pkg = call.argument<String>("packageName") ?: ""
                    val mins = call.argument<Int>("minutes") ?: 0
                    mainScope.launch(Dispatchers.IO) {
                        repository.setAppLimit(pkg, mins)
                        launch(Dispatchers.Main) { result.success(null) }
                    }
                }
                "getGuardianBlocks" -> {
                    mainScope.launch(Dispatchers.IO) {
                        val blocks = repository.getGuardianBlocks()
                        launch(Dispatchers.Main) { result.success(blocks) }
                    }
                }
                "saveGuardianBlocks" -> {
                    val blocks = call.arguments as? List<String> ?: emptyList()
                    mainScope.launch(Dispatchers.IO) {
                        repository.syncGuardianBlocks(blocks)
                        launch(Dispatchers.Main) { result.success(null) }
                    }
                }

                // Lockdown / Zen Mode Methods
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
                else -> result.notImplemented()
            }
        }
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
                        notifyFlutterUnpinned()
                        isLockdownActive = false
                    } else {
                        handler.postDelayed(this, 1000)
                    }
                }
            }
        }
        handler.postDelayed(monitoringTask!!, 2000)
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
