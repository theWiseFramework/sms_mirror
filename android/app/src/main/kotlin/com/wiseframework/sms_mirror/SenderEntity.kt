package com.wiseframework.sms_mirror

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id
import io.objectbox.annotation.Index
import io.objectbox.annotation.Convert
import io.objectbox.converter.PropertyConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.objectbox.annotation.Unique


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
    companion object {
        private val gson = Gson()
        private val type = object : TypeToken<List<String>>() {}.type
    }

    override fun convertToEntityProperty(databaseValue: String?): List<String> {
        if (databaseValue.isNullOrBlank()) return emptyList()
        return gson.fromJson(databaseValue, type)
    }

    override fun convertToDatabaseValue(entityProperty: List<String>?): String {
        return gson.toJson(entityProperty ?: emptyList<String>())
    }
}