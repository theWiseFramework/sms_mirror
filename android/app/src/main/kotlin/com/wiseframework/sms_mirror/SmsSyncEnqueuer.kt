package com.wiseframework.sms_mirror

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.workDataOf
import java.util.concurrent.TimeUnit

object SmsSyncEnqueuer {

    fun enqueueImmediate(context: Context, smsId: Long) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val work = OneTimeWorkRequestBuilder<SmsSyncWorker>()
            .setInputData(workDataOf("sms_id" to smsId))
            .setConstraints(constraints)
            // ✅ Make it urgent; if quota is exceeded, it will downgrade gracefully.
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .setBackoffCriteria(
                BackoffPolicy.EXPONENTIAL,
                10, TimeUnit.SECONDS
            )
            .build()

        WorkManager.getInstance(context).enqueueUniqueWork(
            "sms_sync_$smsId",
            ExistingWorkPolicy.KEEP,
            work
        )
    }
}
