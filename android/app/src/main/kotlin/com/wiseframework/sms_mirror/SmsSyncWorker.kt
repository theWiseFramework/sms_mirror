package com.wiseframework.sms_mirror

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.ServiceInfo
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import io.objectbox.Box
import okhttp3.OkHttpClient
import java.util.concurrent.TimeUnit
import kotlin.collections.plusAssign
import kotlin.compareTo

class SmsSyncWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    private val smsLogBox: Box<SmsLogEntity> by lazy {
        ObjectBox.store.boxFor(SmsLogEntity::class.java)
    }

    override suspend fun doWork(): Result {
        setForeground(createForegroundInfo())

        val smsId = inputData.getLong("sms_id", 0L)
        if (smsId == 0L) return Result.failure()

        val entity = smsLogBox.get(smsId) ?: return Result.success()

        // If already synced, no-op
        if (entity.synced || entity.syncState == SmsLogEntity.SYNC_SYNCED) {
            return Result.success()
        }

        if (entity.attempts >= 10) {
            entity.synced = false
            entity.syncState = SmsLogEntity.SYNC_FAILED_PERMANENT
            entity.lastError = "Max retries exceeded"
            smsLogBox.put(entity)
            return Result.failure()
        }

        // Mark in-flight
        entity.syncState = SmsLogEntity.SYNC_IN_FLIGHT
        entity.attempts += 1
        entity.lastError = null
        smsLogBox.put(entity)

        return Result.success()
    }

    private fun createForegroundInfo(): ForegroundInfo {
        ensureChannel()

        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setContentTitle("SMS Mirror syncing transactions")
            .setContentText("Uploading new SMS transaction…")
            .setSmallIcon(R.drawable.stat_sms_notify_sync)
            .setOngoing(true)
            .build()

        val serviceType =
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC

        // Notification ID must be stable per worker type
        return ForegroundInfo(NOTIF_ID, notification, serviceType)
    }

    private fun ensureChannel() {
        val nm = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = nm.getNotificationChannel(CHANNEL_ID)
        if (existing != null) return

        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Transaction Sync",
                NotificationManager.IMPORTANCE_LOW
            )
        )
    }

    companion object {
        private const val CHANNEL_ID = "sms_mirror_sync"
        private const val NOTIF_ID = 0x2211

        private val http: OkHttpClient = OkHttpClient.Builder()
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(10, TimeUnit.SECONDS)
            .writeTimeout(10, TimeUnit.SECONDS)
            .build()
    }
}