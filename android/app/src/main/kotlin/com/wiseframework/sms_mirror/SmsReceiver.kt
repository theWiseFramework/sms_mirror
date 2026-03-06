package com.wiseframework.sms_mirror

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        if (parts.isEmpty()) return

        val sender = parts.first().displayOriginatingAddress
        if (!SenderList.isAllowed(sender)) return

        // Extract senders and timestamps
        val senders = parts.map { it.displayOriginatingAddress ?: "unknown" }.toSet()
        val timestamps = parts.map { it.timestampMillis }.toSet()

        val canJoin =
            parts.size > 1 &&
                    senders.size == 1 &&
                    timestamps.size == 1

        if (canJoin) {
            // Multipart SMS — join all bodies
            val sender = senders.first()
            val timestamp = timestamps.first()
            val fullBody = buildString {
                parts.forEach { append(it.messageBody ?: "") }
            }

            saveToObjectBox(
                context = context,
                sender = sender,
                timestampMillis = timestamp,
                body = fullBody,
                partsCount = parts.size,
                strategy = "JOIN_SENDER_TIMESTAMP"
            )
        } else {
            // Single or ambiguous — store individually
            parts.forEach { msg ->
                saveToObjectBox(
                    context = context,
                    sender = msg.displayOriginatingAddress ?: "unknown",
                    timestampMillis = msg.timestampMillis,
                    body = msg.messageBody ?: "",
                    partsCount = 1,
                    strategy = "SINGLE_OR_NO_JOIN"
                )
            }
        }
    }

    private fun saveToObjectBox(
        context: Context,
        sender: String,
        timestampMillis: Long,
        body: String,
        partsCount: Int,
        strategy: String
    ) {
        val id = SmsLogRepository.saveIncoming(
            sender = sender,
            timestampMillis = timestampMillis,
            body = body,
            partsCount = partsCount,
            strategy = strategy
        )
        SmsSyncEnqueuer.enqueueImmediate(context, id)
    }
}