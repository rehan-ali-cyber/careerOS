package com.example.careeros.blocking

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat

class AppMonitorService : Service() {

    private lateinit var blockingManager: AppBlockingManager

    companion object {
        private const val CHANNEL_ID = "app_blocking_channel"
        private const val NOTIFICATION_ID = 1001
        const val ACTION_START = "ACTION_START_MONITORING"
        const val ACTION_STOP = "ACTION_STOP_MONITORING"
        var isRunning = false

        fun start(context: android.content.Context) {
            val intent = Intent(context, AppMonitorService::class.java).apply { action = ACTION_START }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.startForegroundService(intent)
            else context.startService(intent)
        }

        fun stop(context: android.content.Context) {
            context.startService(Intent(context, AppMonitorService::class.java).apply { action = ACTION_STOP })
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            if (::blockingManager.isInitialized) blockingManager.stopMonitoring()
            isRunning = false
            stopForeground(true)
            stopSelf()
            return START_NOT_STICKY
        }
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
        blockingManager = AppBlockingManager.getInstance(applicationContext)
        blockingManager.setBlockingEventListener(object : AppBlockingManager.BlockingEventListener {
            override fun onAppBlocked(packageName: String, appName: String) {}
            override fun onInAppContentBlocked(packageName: String, keyword: String) {}
        })
        blockingManager.startMonitoring()
        isRunning = true
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        if (::blockingManager.isInitialized) blockingManager.stopMonitoring()
        isRunning = false
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "App Blocking", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Monitors and blocks restricted apps"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val pm = packageManager
        val launchIntent = pm.getLaunchIntentForPackage(packageName)
        val pendingIntent = if (launchIntent != null) {
            PendingIntent.getActivity(
                this, 0,
                launchIntent,
                PendingIntent.FLAG_IMMUTABLE
            )
        } else null
        
        val stopIntent = PendingIntent.getService(
            this, 1,
            Intent(this, AppMonitorService::class.java).apply { action = ACTION_STOP },
            PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("App Blocking Active")
            .setContentText("Monitoring for restricted apps")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .addAction(android.R.drawable.ic_delete, "Stop", stopIntent)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }
}
