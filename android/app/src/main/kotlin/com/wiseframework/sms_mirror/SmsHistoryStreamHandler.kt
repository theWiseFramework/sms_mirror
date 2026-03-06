package com.wiseframework.sms_mirror

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import io.objectbox.Box

class SmsHistoryStreamHandler : EventChannel.StreamHandler {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val smsLogBox: Box<SmsLogEntity> by lazy {
        ObjectBox.store.boxFor(SmsLogEntity::class.java)
    }

    private var sink: EventChannel.EventSink? = null
    private var lastSignature: String? = null

    private val pollTask = object : Runnable {
        override fun run() {
            if (sink == null) return
            emitIfChanged(force = false)
            mainHandler.postDelayed(this, POLL_INTERVAL_MS)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        lastSignature = null
        emitIfChanged(force = true)
        mainHandler.postDelayed(pollTask, POLL_INTERVAL_MS)
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        lastSignature = null
        mainHandler.removeCallbacks(pollTask)
    }

    private fun emitIfChanged(force: Boolean) {
        val eventSink = sink ?: return

        val tracked = smsLogBox.all
            .asSequence()
            .filter { SenderList.isAllowed(it.sender) }
            .sortedWith(
                compareByDescending<SmsLogEntity> { it.timestampMillis }
                    .thenByDescending { it.id }
            )
            .take(MAX_HISTORY_ITEMS)
            .toList()

        val signature = tracked.joinToString("|") { entity ->
            "${entity.id}:${entity.syncState}:${entity.attempts}:${entity.syncedAtMillis}:${entity.lastError.orEmpty()}"
        }

        if (!force && signature == lastSignature) return
        lastSignature = signature

        val payload = tracked.map { entity ->
            mapOf(
                "id" to entity.id,
                "sender" to entity.sender,
                "body" to entity.body,
                "timestampMillis" to entity.timestampMillis,
                "partsCount" to entity.partsCount,
                "assemblyStrategy" to entity.assemblyStrategy,
                "synced" to entity.synced,
                "syncState" to entity.syncState,
                "syncStateLabel" to syncStateLabel(entity.syncState),
                "attempts" to entity.attempts,
                "lastError" to entity.lastError,
                "createdAtMillis" to entity.createdAtMillis,
                "syncedAtMillis" to entity.syncedAtMillis
            )
        }

        eventSink.success(payload)
    }

    private fun syncStateLabel(state: Int): String {
        return when (state) {
            SmsLogEntity.SYNC_PENDING -> "PENDING"
            SmsLogEntity.SYNC_IN_FLIGHT -> "IN_FLIGHT"
            SmsLogEntity.SYNC_SYNCED -> "SYNCED"
            SmsLogEntity.SYNC_RETRY -> "RETRY"
            SmsLogEntity.SYNC_FAILED_PERMANENT -> "FAILED"
            else -> "UNKNOWN"
        }
    }

    companion object {
        private const val POLL_INTERVAL_MS = 1000L
        private const val MAX_HISTORY_ITEMS = 500
    }
}

