package com.example.careeros.blocking

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.CountDownTimer
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView

class BlockScreenActivity : Activity() {

    companion object {
        const val EXTRA_PACKAGE_NAME = "extra_package_name"
        const val EXTRA_APP_NAME = "extra_app_name"
        const val EXTRA_KEYWORD = "extra_keyword"
    }

    private var countDownTimer: CountDownTimer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )

        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            gravity = android.view.Gravity.CENTER
            setBackgroundColor(android.graphics.Color.parseColor("#1A1A2E"))
            setPadding(64, 64, 64, 64)
        }

        val iconView = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_lock_lock)
            layoutParams = android.widget.LinearLayout.LayoutParams(200, 200).apply {
                gravity = android.view.Gravity.CENTER_HORIZONTAL
                bottomMargin = 48
            }
            setColorFilter(android.graphics.Color.parseColor("#E94560"))
        }

        val titleText = TextView(this).apply {
            text = "Access Blocked"
            textSize = 28f
            setTextColor(android.graphics.Color.WHITE)
            gravity = android.view.Gravity.CENTER
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { bottomMargin = 24 }
        }

        val appName = intent.getStringExtra(EXTRA_APP_NAME) ?: "This app"
        val keyword = intent.getStringExtra(EXTRA_KEYWORD)

        val messageText = TextView(this).apply {
            text = if (keyword != null) "\"$appName\" contains restricted content:\n\"$keyword\""
                   else "\"$appName\" is restricted."
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#AAAAAA"))
            gravity = android.view.Gravity.CENTER
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { bottomMargin = 48 }
        }

        val goBackButton = Button(this).apply {
            text = "← Go Back"
            textSize = 16f
            setTextColor(android.graphics.Color.WHITE)
            setBackgroundColor(android.graphics.Color.parseColor("#E94560"))
            layoutParams = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { bottomMargin = 16 }
            setOnClickListener { goHome() }
        }

        val countdownText = TextView(this).apply {
            id = View.generateViewId()
            text = ""
            textSize = 13f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            gravity = android.view.Gravity.CENTER
        }

        layout.addView(iconView)
        layout.addView(titleText)
        layout.addView(messageText)
        layout.addView(goBackButton)
        layout.addView(countdownText)
        setContentView(layout)

        countDownTimer = object : CountDownTimer(5000, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                countdownText.text = "Returning home in ${millisUntilFinished / 1000}s…"
            }
            override fun onFinish() { goHome() }
        }.start()
    }

    private fun goHome() {
        startActivity(Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        })
        finish()
    }

    override fun onBackPressed() { goHome() }
    override fun onDestroy() { countDownTimer?.cancel(); super.onDestroy() }
}
