package com.wiseframework.sms_mirror

import android.app.Application
import android.content.Context
import io.objectbox.BoxStore

class App : Application() {

    override fun onCreate() {
        super.onCreate()
        ObjectBox.init(this)
        SenderList.init()
    }
}

object ObjectBox {
    lateinit var store: BoxStore
        private set

    fun init(context: Context) {
        if (::store.isInitialized) return
        store = MyObjectBox.builder()
            .androidContext(context.applicationContext)
            .build()
    }
}