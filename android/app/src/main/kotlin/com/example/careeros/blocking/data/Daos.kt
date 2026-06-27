package com.example.careeros.blocking.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface BlockedAppDao {
    @Query("SELECT * FROM blocked_apps")
    fun getAllBlockedApps(): Flow<List<BlockedApp>>

    @Query("SELECT * FROM blocked_apps WHERE packageName = :packageName LIMIT 1")
    suspend fun getApp(packageName: String): BlockedApp?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(app: BlockedApp)

    @Delete
    suspend fun delete(app: BlockedApp)
}

@Dao
interface ScheduleDao {
    @Query("SELECT * FROM block_schedules WHERE packageName = :packageName")
    suspend fun getSchedulesForApp(packageName: String): List<BlockSchedule>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(schedule: BlockSchedule)

    @Query("DELETE FROM block_schedules WHERE packageName = :packageName")
    suspend fun deleteSchedulesForApp(packageName: String)
}

@Dao
interface FocusSessionDao {
    @Query("SELECT * FROM focus_sessions WHERE isActive = 1 AND endTimeMs > :now LIMIT 1")
    suspend fun getActiveSession(now: Long): FocusSession?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(session: FocusSession)

    @Query("UPDATE focus_sessions SET isActive = 0")
    suspend fun stopAllSessions()
}
