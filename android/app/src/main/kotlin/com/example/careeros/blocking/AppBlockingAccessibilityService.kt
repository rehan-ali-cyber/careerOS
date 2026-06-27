package com.example.careeros.blocking

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
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

class AppBlockingAccessibilityService : AccessibilityService() {

    private val TAG = "BlockingAccessibility"
    private lateinit var blockingManager: AppBlockingManager
    private var lastCheckedPackage: String? = null
    private var lastCheckedText: String? = null

    // Overlay Management
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isOverlayShowing = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility Service Connected")
        
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        
        blockingManager = AppBlockingManager.getInstance(applicationContext)
        blockingManager.setBlockingEventListener(object : AppBlockingManager.BlockingEventListener {
            override fun onAppBlocked(packageName: String, appName: String) {}
            override fun onInAppContentBlocked(packageName: String, keyword: String) {}
            override fun requestSurgicalBack() {
                performGlobalAction(GLOBAL_ACTION_BACK)
            }
            override fun requestOverlay(show: Boolean, message: String?) {
                if (show) showOverlay(message ?: "Content Restricted")
                else hideOverlay()
            }
        })
        
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
    }

    private fun showOverlay(message: String) {
        if (isOverlayShowing) {
            overlayView?.findViewById<TextView>(12345)?.text = message
            return
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            (resources.displayMetrics.heightPixels * 0.85).toInt(), // Cover top 85%
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.TOP

        val container = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#FB000000")) // Deep Black
            val tv = TextView(this.context).apply {
                id = 12345
                text = message
                setTextColor(Color.WHITE)
                textSize = 22f
                gravity = Gravity.CENTER
                setPadding(60, 60, 60, 60)
            }
            addView(tv, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            ))
        }

        overlayView = container
        
        try {
            windowManager?.addView(overlayView, params)
            isOverlayShowing = true
            Log.d(TAG, "Surgical Overlay Displayed")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add overlay: ${e.message}")
        }
    }

    private fun hideOverlay() {
        if (!isOverlayShowing) return
        try {
            windowManager?.removeView(overlayView)
            isOverlayShowing = false
            Log.d(TAG, "Surgical Overlay Removed")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to remove overlay")
        }
    }


    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName || pkg == "com.android.systemui") return
        
        val rootNode = rootInActiveWindow ?: return
        
        // --- 1. FULL-SCREEN VIDEO DETECTION (IDs Only - NO KEYWORDS) ---
        val isShortsFullscreen = checkNodeForIdOnly(rootNode, "com.google.android.youtube:id/shorts_player_view")
        val isReelsFullscreen = checkNodeForIdOnly(rootNode, "com.instagram.android:id/clips_viewer_container")
        val isSpotlightFullscreen = checkNodeForIdOnly(rootNode, "com.snapchat.android:id/spotlight_tab_container")

        if (isShortsFullscreen || isReelsFullscreen || isSpotlightFullscreen) {
            val type = when {
                isShortsFullscreen -> "Shorts"
                isReelsFullscreen -> "Reels"
                else -> "Spotlight"
            }
            blockingManager.checkInAppContent(pkg, type)
            return
        }

        // --- 2. SURGICAL FEATURE DETECTION (Contextual) ---
        if (pkg == "com.instagram.android") {
            if (checkNodeForIdOnly(rootNode, "com.instagram.android:id/action_bar_title")) {
                val title = findTextById(rootNode, "com.instagram.android:id/action_bar_title")
                if (title?.contains("Messages", ignoreCase = true) == true || title?.contains("Direct", ignoreCase = true) == true) {
                    blockingManager.checkInAppContent(pkg, "InstaDM")
                    return
                }
            }
        }
        
        if (pkg == "com.snapchat.android") {
            if (checkNodeForIdOnly(rootNode, "com.snapchat.android:id/chat_v2_container")) {
                blockingManager.checkInAppContent(pkg, "SnapChatUI")
                return
            }
        }

        // Fallback to text extraction for custom user-defined keywords (Shows FULL block screen)
        val screenText = extractTextFromNode(rootNode)
        if (pkg == lastCheckedPackage && screenText == lastCheckedText) return
        lastCheckedPackage = pkg
        lastCheckedText = screenText
        
        if (screenText.isNotBlank()) blockingManager.checkInAppContent(pkg, screenText)
    }

    private fun checkNodeForIdOnly(node: AccessibilityNodeInfo?, targetId: String): Boolean {
        if (node == null) return false
        if (node.viewIdResourceName == targetId) return true
        
        for (i in 0 until node.childCount) {
            if (checkNodeForIdOnly(node.getChild(i), targetId)) return true
        }
        return false
    }

    private fun findTextById(node: AccessibilityNodeInfo?, targetId: String): String? {
        if (node == null) return null
        if (node.viewIdResourceName == targetId) return node.text?.toString()
        
        for (i in 0 until node.childCount) {
            val result = findTextById(node.getChild(i), targetId)
            if (result != null) return result
        }
        return null
    }

    override fun onInterrupt() {
        Log.w(TAG, "Accessibility Service Interrupted")
    }

    private fun extractTextFromNode(node: AccessibilityNodeInfo?, depth: Int = 0, maxDepth: Int = 8, collected: StringBuilder = StringBuilder()): String {
        if (node == null || depth > maxDepth) return collected.toString()
        node.text?.let { collected.append(it).append(" ") }
        node.contentDescription?.let { collected.append(it).append(" ") }
        for (i in 0 until minOf(node.childCount, 50)) {
            try {
                extractTextFromNode(node.getChild(i), depth + 1, maxDepth, collected)
            } catch (e: Exception) {}
        }
        return collected.toString()
    }
}
