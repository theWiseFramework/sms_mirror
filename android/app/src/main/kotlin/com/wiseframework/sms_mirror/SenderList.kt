package com.wiseframework.sms_mirror

import io.objectbox.Box
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import java.util.concurrent.atomic.AtomicReference

object SenderList {
    private data class SenderRule(
        val normalized: String,
        val compact: String,
        val webhooks: List<String>
    )

    private val cached = AtomicReference<List<SenderRule>>(emptyList())
    private lateinit var box: Box<SenderEntity>

    fun init() {
        box = ObjectBox.store.boxFor(SenderEntity::class.java)
        refreshFromDb()
    }

    @Synchronized
    fun refreshFromDb() {
        val all = box.all.mapNotNull { entity ->
            val normalizedName = normalize(entity.name)
            if (normalizedName.isEmpty()) return@mapNotNull null
            val webhooks = sanitizeWebhooks(entity.webhooks)
            if (webhooks.isEmpty()) return@mapNotNull null

            SenderRule(
                normalized = normalizedName,
                compact = compact(normalizedName),
                webhooks = webhooks
            )
        }
        cached.set(all)
    }

    fun isAllowed(rawSender: String?): Boolean {
        return resolve(rawSender) != null
    }

    fun webhooksFor(rawSender: String?): List<String> {
        return resolve(rawSender)?.webhooks ?: emptyList()
    }

    @Synchronized
    fun upsert(rawSender: String?, rawWebhooks: List<String>): SenderEntity {
        val sender = normalize(rawSender)
        require(sender.isNotEmpty()) { "Sender is required" }

        val webhooks = sanitizeWebhooks(rawWebhooks)
        require(webhooks.isNotEmpty()) { "At least one valid webhook URL is required" }

        val existing = box.all.firstOrNull { it.name == sender }
        val entity =
            existing?.apply {
                name = sender
                this.webhooks = webhooks
            } ?: SenderEntity(name = sender, webhooks = webhooks)

        box.put(entity)
        refreshFromDb()
        return entity
    }

    @Synchronized
    fun remove(rawSender: String?): Boolean {
        val sender = normalize(rawSender)
        if (sender.isEmpty()) return false

        val existing = box.all.firstOrNull { it.name == sender } ?: return false
        box.remove(existing.id)
        refreshFromDb()
        return true
    }

    fun list(): List<SenderEntity> {
        return box.all
            .sortedBy { it.name }
            .mapNotNull {
                val webhooks = sanitizeWebhooks(it.webhooks)
                if (webhooks.isEmpty()) return@mapNotNull null
                it.copy(
                    name = normalize(it.name),
                    webhooks = webhooks
                )
            }
    }

    private fun resolve(rawSender: String?): SenderRule? {
        val sender = normalize(rawSender)
        if (sender.isEmpty()) return null

        val compactSender = compact(sender)
        val all = cached.get()

        all.firstOrNull { it.normalized == sender }?.let { return it }
        all.firstOrNull { it.compact == compactSender }?.let { return it }

        return all
            .asSequence()
            .filter { it.compact.length >= 3 && compactSender.contains(it.compact) }
            .maxByOrNull { it.compact.length }
    }

    private fun normalize(s: String?): String {
        return (s ?: "").trim().uppercase()
    }

    private fun compact(s: String): String {
        return s.filter { it.isLetterOrDigit() }
    }

    private fun sanitizeWebhooks(rawWebhooks: List<String>): List<String> {
        return rawWebhooks
            .asSequence()
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .mapNotNull { url ->
                val parsed = url.toHttpUrlOrNull() ?: return@mapNotNull null
                val scheme = parsed.scheme.lowercase()
                if (scheme != "http" && scheme != "https") return@mapNotNull null
                parsed.toString().trimEnd('/')
            }
            .distinct()
            .toList()
    }
}
