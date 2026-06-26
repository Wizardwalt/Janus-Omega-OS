package com.janus.omega

import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

object RuntimeClient {
    private const val BASE_URL = "http://10.0.2.2:8080"

    fun get(path: String): String {
        return try {
            val url = URL(BASE_URL + path)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "GET"
            conn.connectTimeout = 2000
            conn.readTimeout = 2000
            conn.inputStream.bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            "Runtime unavailable: ${e.message}"
        }
    }

    fun post(path: String, body: String = ""): String {
        return try {
            val url = URL(BASE_URL + path)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.connectTimeout = 2000
            conn.readTimeout = 2000
            conn.doOutput = true
            if (body.isNotEmpty()) {
                conn.setRequestProperty("Content-Type", "application/json")
                OutputStreamWriter(conn.outputStream).use { it.write(body) }
            }
            conn.inputStream.bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            "Runtime unavailable: ${e.message}"
        }
    }
}
