package com.wiseframework.sms_mirror

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.wiseframework.sms_mirror/app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "addSender" -> handleAddSender(call, result)
                    "removeSender" -> handleRemoveSender(call, result)
                    "listSenders" -> handleListSenders(result)
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("native_error", e.message, null)
            }
        }
    }

    private fun handleAddSender(call: MethodCall, result: MethodChannel.Result) {
        val sender = call.argument<String>("sender")
        val webhooks = asStringList(call.argument<List<*>>("webhooks"))
        if (sender.isNullOrBlank()) {
            result.error("invalid_args", "Missing sender", null)
            return
        }

        val entity = SenderList.upsert(sender, webhooks)
        result.success(
            mapOf(
                "name" to entity.name,
                "webhooks" to entity.webhooks
            )
        )
    }

    private fun handleRemoveSender(call: MethodCall, result: MethodChannel.Result) {
        val sender = call.argument<String>("sender")
        if (sender.isNullOrBlank()) {
            result.error("invalid_args", "Missing sender", null)
            return
        }

        result.success(SenderList.remove(sender))
    }

    private fun handleListSenders(result: MethodChannel.Result) {
        val data = SenderList.list().map { entity ->
            mapOf(
                "name" to entity.name,
                "webhooks" to entity.webhooks
            )
        }
        result.success(data)
    }

    private fun asStringList(raw: List<*>?): List<String> {
        if (raw == null) return emptyList()
        return raw.mapNotNull { it?.toString() }
    }
}
