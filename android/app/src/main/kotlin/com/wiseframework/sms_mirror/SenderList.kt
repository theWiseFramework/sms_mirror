package com.wiseframework.sms_mirror

import io.objectbox.Box
import java.util.concurrent.atomic.AtomicReference
import kotlin.collections.any

object SenderList {
    private val cached = AtomicReference<Set<String>>(emptySet())
    private lateinit var box: Box<SenderEntity>

    fun init() {
        box = ObjectBox.store.boxFor(SenderEntity::class.java)
        refreshFromDb()
    }

    fun refreshFromDb() {
        val all = box.all.map { it.name }.toSet()
        cached.set(all)
    }

    fun isAllowed(rawSender: String?): Boolean {
        val sender = normalize(rawSender)
        if (sender.isEmpty()) return false

        val allow = cached.get()

        // Exact match
        if (allow.contains(sender)) return true

        // Optional: "contains" style matching for alphanumeric senders
        // e.g. sender might be "MPESA" or "M-PESA"
        // Keep simple and predictable:
        return allow.any { it.isNotBlank() && sender.contains(it) }
    }

    private fun normalize(s: String?): String {
        return (s ?: "").trim().uppercase()
    }
}