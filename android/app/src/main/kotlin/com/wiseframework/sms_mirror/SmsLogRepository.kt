package com.wiseframework.sms_mirror

import io.objectbox.Box

object SmsLogRepository {

    private val box: Box<SmsLogEntity> by lazy {
        ObjectBox.store.boxFor(SmsLogEntity::class.java)
    }

    fun saveIncoming(
        sender: String,
        timestampMillis: Long,
        body: String,
        partsCount: Int,
        strategy: String
    ): Long {
        val existing = box.all.firstOrNull {
            it.sender == sender &&
                    it.timestampMillis == timestampMillis &&
                    it.body == body
        }
        if (existing != null) return existing.id

        val entity = SmsLogEntity(
            sender = sender,
            timestampMillis = timestampMillis,
            body = body,
            partsCount = partsCount,
            assemblyStrategy = strategy,
            synced = false,
            syncState = SmsLogEntity.SYNC_PENDING
        )
        val id = box.put(entity)
        return id
    }
}
