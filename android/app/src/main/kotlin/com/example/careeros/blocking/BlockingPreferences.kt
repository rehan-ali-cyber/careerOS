package com.example.careeros.blocking

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

object BlockingPreferences {

    private const val PREFS_NAME = "app_blocking_prefs"
    private const val KEY_BLOCKED_APPS = "blocked_apps"
    private const val KEY_BLOCKED_KEYWORDS = "blocked_keywords"
    private const val KEY_SCHEDULES = "blocking_schedules"
    private const val KEY_APP_LIMITS = "app_limits"
    private val gson = Gson()

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun saveBlockedApps(context: Context, apps: Set<String>) {
        prefs(context).edit().putString(KEY_BLOCKED_APPS, gson.toJson(apps)).apply()
    }

    fun getBlockedApps(context: Context): Set<String> {
        val json = prefs(context).getString(KEY_BLOCKED_APPS, null) ?: return emptySet()
        return try {
            val type = object : TypeToken<Set<String>>() {}.type
            gson.fromJson(json, type) ?: emptySet()
        } catch (e: Exception) { emptySet() }
    }

    fun saveBlockedKeywords(context: Context, keywords: Set<String>) {
        prefs(context).edit().putString(KEY_BLOCKED_KEYWORDS, gson.toJson(keywords)).apply()
    }

    fun getBlockedKeywords(context: Context): Set<String> {
        val json = prefs(context).getString(KEY_BLOCKED_KEYWORDS, null) ?: return emptySet()
        return try {
            val type = object : TypeToken<Set<String>>() {}.type
            gson.fromJson(json, type) ?: emptySet()
        } catch (e: Exception) { emptySet() }
    }

    fun saveSchedules(context: Context, schedules: List<BlockSchedule>) {
        prefs(context).edit().putString(KEY_SCHEDULES, gson.toJson(schedules)).apply()
    }

    fun getSchedules(context: Context): List<BlockSchedule> {
        val json = prefs(context).getString(KEY_SCHEDULES, null) ?: return emptyList()
        return try {
            val type = object : TypeToken<List<BlockSchedule>>() {}.type
            gson.fromJson(json, type) ?: emptyList()
        } catch (e: Exception) { emptyList() }
    }

    fun saveAppLimits(context: Context, limits: Map<String, Int>) {
        prefs(context).edit().putString(KEY_APP_LIMITS, gson.toJson(limits)).apply()
    }

    fun getAppLimits(context: Context): Map<String, Int> {
        val json = prefs(context).getString(KEY_APP_LIMITS, null) ?: return emptyMap()
        return try {
            val type = object : TypeToken<Map<String, Int>>() {}.type
            gson.fromJson(json, type) ?: emptyMap()
        } catch (e: Exception) { emptyMap() }
    }

    fun clearAll(context: Context) {
        prefs(context).edit().clear().apply()
    }
}
