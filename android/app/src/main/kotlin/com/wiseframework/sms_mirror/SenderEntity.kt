package com.wiseframework.sms_mirror

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id
import io.objectbox.annotation.Index
import io.objectbox.annotation.Convert
import io.objectbox.converter.PropertyConverter
import io.objectbox.annotation.Unique
import org.json.JSONArray


@Entity
data class SenderEntity(
    @Id var id: Long = 0,

    @Unique
    @Index
    var name: String = "",

    @Convert(converter = StringListConverter::class, dbType = String::class)
    var webhooks: List<String> = emptyList()
)

class StringListConverter : PropertyConverter<List<String>, String> {
    override fun convertToEntityProperty(databaseValue: String?): List<String> {
        if (databaseValue.isNullOrBlank()) return emptyList()
        return try {
            val arr = JSONArray(databaseValue)
            buildList {
                for (i in 0 until arr.length()) {
                    val value = arr.optString(i, "").trim()
                    if (value.isNotEmpty()) add(value)
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    override fun convertToDatabaseValue(entityProperty: List<String>?): String {
        val arr = JSONArray()
        (entityProperty ?: emptyList()).forEach { arr.put(it) }
        return arr.toString()
    }
}
