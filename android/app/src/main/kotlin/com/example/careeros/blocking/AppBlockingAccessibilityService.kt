package com.example.careeros.blocking

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AppBlockingAccessibilityService : AccessibilityService() {

    private val TAG = "BlockingAccessibility"
    private lateinit var blockingManager: AppBlockingManager
    private var lastCheckedPackage: String? = null
    private var lastCheckedText: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Accessibility Service Connected")
        blockingManager = AppBlockingManager.getInstance(applicationContext)
        blockingManager.setBlockingEventListener(object : AppBlockingManager.BlockingEventListener {
            override fun onAppBlocked(packageName: String, appName: String) {}
            override fun onInAppContentBlocked(packageName: String, keyword: String) {}
            override fun requestSurgicalBack() {
                Log.i(TAG, "Executing GLOBAL_ACTION_BACK for surgical block")
                performGlobalAction(GLOBAL_ACTION_BACK)
            }
        })
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName || pkg == "com.android.systemui") return
        
        val rootNode = rootInActiveWindow ?: return
        
        // --- DEEP INSPECTION (FULL SCREEN ONLY) ---
        // We look for specific view IDs that represent the full-screen players
        // This avoids blocking small preview tiles on the home feed.
        val isShortsFullscreen = checkNodeForIdOnly(rootNode, "com.google.android.youtube:id/shorts_player_view")
        val isReelsFullscreen = checkNodeForIdOnly(rootNode, "com.instagram.android:id/clips_viewer_container")
        val isSpotlightFullscreen = checkNodeForIdOnly(rootNode, "com.snapchat.android:id/spotlight_tab_container")

        if (isShortsFullscreen || isReelsFullscreen || isSpotlightFullscreen) {
            val type = when {
                isShortsFullscreen -> "Shorts"
                isReelsFullscreen -> "Reels"
                else -> "Spotlight"
            }
            Log.i(TAG, "Full-Screen Surgical Match: $type in $pkg")
            blockingManager.checkInAppContent(pkg, type)
            return
        }

        // Fallback to text extraction only for custom keywords (NOT for surgical blocks)
        val screenText = extractTextFromNode(rootNode)
        if (pkg == lastCheckedPackage && screenText == lastCheckedText) return
        lastCheckedPackage = pkg
        lastCheckedText = screenText
        
        if (screenText.isNotBlank()) blockingManager.checkInAppContent(pkg, screenText)
    }

    private fun checkNodeForIdOnly(node: AccessibilityNodeInfo?, targetId: String): Boolean {
        if (node == null) return false
        
        if (node.viewIdResourceName == targetId) {
            // VERIFY DIMENSIONS: Ensure it's likely full screen
            val rect = android.graphics.Rect()
            node.getBoundsInScreen(rect)
            val screenHeight = resources.displayMetrics.heightPixels
            // If the viewer takes up more than 70% of the screen height, it's the full-screen player
            if (rect.height() > (screenHeight * 0.7)) {
                return true
            }
        }
        
        for (i in 0 until node.childCount) {
            if (checkNodeForIdOnly(node.getChild(i), targetId)) return true
        }
        return false
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
