package com.example.careeros.blocking

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.FrameLayout
import android.widget.TextView
import com.example.careeros.blocking.data.AppBlockingDatabase
import com.example.careeros.blocking.data.AppBlockingRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class AppBlockingAccessibilityService : AccessibilityService() {

    private val TAG = "SurgicalWarden"
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private lateinit var repository: AppBlockingRepository

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isOverlayShowing = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Surgical Warden: Structural Detection Active")
        
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val db = AppBlockingDatabase.getInstance(applicationContext)
        repository = AppBlockingRepository(applicationContext, db)

        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 50
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString() ?: return
        if (packageName == this.packageName || packageName == "com.android.systemui") return

        val rootNode = rootInActiveWindow ?: return

        serviceScope.launch {
            if (repository.shouldBlock(packageName)) {
                launch(Dispatchers.Main) { 
                    hideOverlay()
                    launchBlockScreen(packageName) 
                }
                return@launch
            }

            val isShorts = checkNodeForId(rootNode, "com.google.android.youtube:id/shorts_player_view")
            val isReels = checkNodeForId(rootNode, "com.instagram.android:id/clips_viewer_container")
            val isSpotlight = checkNodeForId(rootNode, "com.snapchat.android:id/spotlight_tab_container")
            val isInstaDM = checkNodeForId(rootNode, "com.instagram.android:id/message_list_recycler_view")
            val isSnapChat = checkNodeForId(rootNode, "com.snapchat.android:id/chat_v2_container")

            launch(Dispatchers.Main) {
                val shouldShow = when {
                    isShorts && repository.isGuardianEnabled("YouTube Shorts") -> true
                    isReels && repository.isGuardianEnabled("Instagram Reels") -> true
                    isSpotlight && repository.isGuardianEnabled("Snapchat Spotlight") -> true
                    isInstaDM && repository.isGuardianEnabled("Instagram DMs") -> true
                    isSnapChat && repository.isGuardianEnabled("Snapchat Chat") -> true
                    else -> false
                }

                if (shouldShow) {
                    showOverlay("Addiction Blocked: Return to Mission")
                } else {
                    hideOverlay()
                }
            }
        }
    }

    private fun checkNodeForId(node: AccessibilityNodeInfo?, targetId: String): Boolean {
        if (node == null) return false
        if (node.viewIdResourceName == targetId) return true
        for (i in 0 until node.childCount) {
            try {
                if (checkNodeForId(node.getChild(i), targetId)) return true
            } catch (e: Exception) {}
        }
        return false
    }

    private fun showOverlay(message: String) {
        if (isOverlayShowing) return

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            (resources.displayMetrics.heightPixels * 0.85).toInt(),
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP

        val container = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#FB000000"))
            val tv = TextView(this.context).apply {
                text = message
                setTextColor(Color.WHITE)
                textSize = 20f
                gravity = Gravity.CENTER
                setPadding(60, 60, 60, 60)
            }
            addView(tv, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        }

        overlayView = container
        try {
            windowManager?.addView(overlayView, params)
            isOverlayShowing = true
        } catch (e: Exception) {
            Log.e(TAG, "Overlay Error: ${e.message}")
        }
    }

    private fun hideOverlay() {
        if (!isOverlayShowing) return
        try {
            windowManager?.removeView(overlayView)
            isOverlayShowing = false
        } catch (e: Exception) {}
    }

    private fun launchBlockScreen(packageName: String) {
        val intent = Intent(this, BlockScreenActivity::class.java).apply {
            putExtra(BlockScreenActivity.EXTRA_PACKAGE_NAME, packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
    }

    override fun onInterrupt() {}
}
