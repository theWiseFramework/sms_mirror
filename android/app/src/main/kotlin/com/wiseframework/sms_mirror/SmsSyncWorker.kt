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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.security.MessageDigest
import java.util.concurrent.TimeUnit

class SmsSyncWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    private val smsLogBox: Box<SmsLogEntity> by lazy {
        ObjectBox.store.boxFor(SmsLogEntity::class.java)
    }

    override suspend fun doWork(): Result {
        val smsId = inputData.getLong(KEY_SMS_ID, 0L)
        if (smsId == 0L) return Result.failure()

        val entity = smsLogBox.get(smsId) ?: return Result.success()

        // If already synced, no-op
        if (entity.synced || entity.syncState == SmsLogEntity.SYNC_SYNCED) {
            return Result.success()
        }

        if (entity.attempts >= MAX_RETRIES) {
            entity.synced = false
            entity.syncState = SmsLogEntity.SYNC_FAILED_PERMANENT
            entity.lastError = "Max retries exceeded"
            smsLogBox.put(entity)
            return Result.failure()
        }

        val webhooks = SenderList.webhooksFor(entity.sender)
        if (webhooks.isEmpty()) {
            entity.synced = false
            entity.syncState = SmsLogEntity.SYNC_FAILED_PERMANENT
            entity.lastError = "No valid webhooks configured for sender ${entity.sender}"
            smsLogBox.put(entity)
            return Result.failure()
        }

        setForeground(createForegroundInfo())

        // Mark in-flight
        entity.syncState = SmsLogEntity.SYNC_IN_FLIGHT
        entity.attempts += 1
        entity.lastError = null
        smsLogBox.put(entity)

        val failures = mutableListOf<String>()
        webhooks.forEach { webhook ->
            try {
                val status = uploadToServer(entity, webhook)
                if (status !in 200..299) {
                    failures += "${short(webhook)} -> HTTP $status"
                }
            } catch (e: Exception) {
                failures += "${short(webhook)} -> ${e.message ?: "Request failed"}"
            }
        }

        if (failures.isEmpty()) {
            entity.synced = true
            entity.syncState = SmsLogEntity.SYNC_SYNCED
            entity.syncedAtMillis = System.currentTimeMillis()
            entity.lastError = null
            smsLogBox.put(entity)
            return Result.success()
        }

        entity.synced = false
        entity.lastError = failures.joinToString(" | ").take(2000)

        if (entity.attempts >= MAX_RETRIES) {
            entity.syncState = SmsLogEntity.SYNC_FAILED_PERMANENT
            smsLogBox.put(entity)
            return Result.failure()
        }

        entity.syncState = SmsLogEntity.SYNC_RETRY
        smsLogBox.put(entity)
        return Result.retry()
    }

    private suspend fun uploadToServer(entity: SmsLogEntity, webhookUrl: String): Int =
        withContext(Dispatchers.IO) {
        val json = JSONObject().apply {
            put("id", entity.id)
            put("sender", entity.sender)
            put("body", entity.body)
            put("timestampMillis", entity.timestampMillis)
            put("partsCount", entity.partsCount)
            put("assemblyStrategy", entity.assemblyStrategy)
            put("fingerprint", fingerprint(entity))
            put("syncedAt", System.currentTimeMillis())
        }

        val body = json.toString().toRequestBody(JSON_MEDIA_TYPE)
        val request = Request.Builder()
            .url(webhookUrl)
            .post(body)
            .build()

        http.newCall(request).execute().use { response ->
            response.code
        }
    }

    private fun fingerprint(entity: SmsLogEntity): String {
        val payload = "${entity.sender}|${entity.timestampMillis}|${entity.body}"
        val digest = MessageDigest.getInstance("SHA-256").digest(payload.toByteArray())
        return digest.joinToString("") { "%02x".format(it) }
    }

    private fun short(url: String): String {
        if (url.length <= 80) return url
        return "${url.take(77)}..."
    }

    private fun createForegroundInfo(): ForegroundInfo {
        ensureChannel()

        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setContentTitle("SMS Mirror syncing")
            .setContentText("Delivering SMS to webhook(s)...")
            .setSmallIcon(R.drawable.stat_sms_notify_sync)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()

        return ForegroundInfo(
            NOTIFICATION_ID,
            notification,
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        )
    }

    private fun ensureChannel() {
        val manager =
            applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "SMS Mirror Sync",
                NotificationManager.IMPORTANCE_LOW
            )
        )
    }

    companion object {
        private const val KEY_SMS_ID = "sms_id"
        private const val MAX_RETRIES = 10
        private const val CHANNEL_ID = "sms_mirror_sync"
        private const val NOTIFICATION_ID = 0x2211
        private val JSON_MEDIA_TYPE = "application/json; charset=utf-8".toMediaType()

        private val http: OkHttpClient = OkHttpClient.Builder()
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(10, TimeUnit.SECONDS)
            .writeTimeout(10, TimeUnit.SECONDS)
            .build()
    }
}
