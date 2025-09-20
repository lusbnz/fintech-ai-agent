package com.ltcn272.finny.core

import android.content.SharedPreferences
import androidx.core.content.edit
import javax.inject.Inject

class LoginStateManager @Inject constructor(private val sp: SharedPreferences) {

    companion object {
        const val K_ACCESS = "access_token"
    }


    fun isLoggedIn(clockSkewSec: Long = 60): Boolean {
        val token = sp.getString(K_ACCESS, null) ?: return false
        return !isJwtExpired(token, clockSkewSec)
    }

    fun clear() {
        sp.edit { clear() }
    }

    private fun isJwtExpired(jwt: String, skewSec: Long): Boolean {
        return try {
            val parts = jwt.split(".")
            if (parts.size < 2) return true
            val payloadJson = String(android.util.Base64.decode(parts[1],
                android.util.Base64.URL_SAFE or android.util.Base64.NO_WRAP))
            val exp = org.json.JSONObject(payloadJson).optLong("exp", 0L)
            if (exp <= 0L) return true
            val now = System.currentTimeMillis() / 1000
            now + skewSec >= exp
        } catch (_: Exception) {
            true
        }
    }
}
