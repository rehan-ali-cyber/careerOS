package com.example.careeros.blocking.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [BlockedApp::class, BlockSchedule::class, FocusSession::class], version = 1, exportSchema = false)
abstract class AppBlockingDatabase : RoomDatabase() {
    abstract fun blockedAppDao(): BlockedAppDao
    abstract fun scheduleDao(): ScheduleDao
    abstract fun focusSessionDao(): FocusSessionDao

    companion object {
        @Volatile
        private var INSTANCE: AppBlockingDatabase? = null

        fun getInstance(context: Context): AppBlockingDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppBlockingDatabase::class.java,
                    "app_blocking_db"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
