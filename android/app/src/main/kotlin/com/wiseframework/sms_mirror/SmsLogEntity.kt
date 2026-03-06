package com.wiseframework.sms_mirror

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id
import io.objectbox.annotation.Index

@Entity
data class SmsLogEntity(
    @Id var id: Long = 0,

    @Index var sender: String = "",
    var body: String = "",
    var timestampMillis: Long = 0,

    // For multipart/debug visibility
    var partsCount: Int = 1,
    var assemblyStrategy: String = "",

    // Sync pipeline (for later)
    var synced: Boolean = false,
    var syncState: Int = SYNC_PENDING,
    var createdAtMillis: Long = System.currentTimeMillis(),
    var syncedAtMillis: Long = 0L,
    var lastError: String? = null,
    var attempts: Int = 0,
) {
    companion object {
        const val SYNC_PENDING = 0
        const val SYNC_IN_FLIGHT = 1
        const val SYNC_SYNCED = 2
        const val SYNC_RETRY = 3
        const val SYNC_FAILED_PERMANENT = 4
    }
}