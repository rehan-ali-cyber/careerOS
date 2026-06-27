package com.example.careeros.blocking

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AppBlockingAccessibilityService : AccessibilityService() {

    private lateinit var blockingManager: AppBlockingManager
    private var lastCheckedPackage: String? = null
    private var lastCheckedText: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        blockingManager = AppBlockingManager(applicationContext)
        blockingManager.loadSavedRules()
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }
        blockingManager.setBlockingEventListener(object : AppBlockingManager.BlockingEventListener {
            override fun onAppBlocked(packageName: String, appName: String) {}
            override fun onInAppContentBlocked(packageName: String, keyword: String) {}
        })
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName || pkg == "com.android.systemui") return
        val rootNode = rootInActiveWindow ?: return
        val screenText = extractTextFromNode(rootNode)
        if (pkg == lastCheckedPackage && screenText == lastCheckedText) return
        lastCheckedPackage = pkg
        lastCheckedText = screenText
        if (screenText.isNotBlank()) blockingManager.checkInAppContent(pkg, screenText)
    }

    override fun onInterrupt() {}

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
