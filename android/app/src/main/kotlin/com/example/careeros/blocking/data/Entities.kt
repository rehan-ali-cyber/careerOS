package com.example.careeros.blocking.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "blocked_apps")
data class BlockedApp(
    @PrimaryKey val packageName: String,
    val appName: String,
    val isWhitelisted: Boolean = false
)

@Entity(tableName = "block_schedules")
data class BlockSchedule(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val packageName: String,
    val startHour: Int,    // 0-23
    val startMinute: Int,  // 0-59
    val endHour: Int,
    val endMinute: Int,
    val daysOfWeek: String // e.g., "1,2,3,4,5,6,7" (Sun=1)
)

@Entity(tableName = "focus_sessions")
data class FocusSession(
    @PrimaryKey val id: String,
    val startTimeMs: Long,
    val endTimeMs: Long,
    val isActive: Boolean = true
)
