package com.ltcn272.finny.core

import android.content.SharedPreferences
import androidx.core.content.edit
import javax.inject.Inject

class TokenManager @Inject constructor(private val sp: SharedPreferences) {
    private val K_ACCESS = "access_token"
    private val K_REFRESH = "refresh_token"
    private val K_FIREBASE_ID_TOKEN = "firebase_id_token"

    fun saveAccessToken(token: String) = sp.edit { putString(K_ACCESS, token) }
    fun saveRefreshToken(token: String) = sp.edit { putString(K_REFRESH, token) }
    fun saveFirebaseIdToken(token: String) = sp.edit { putString(K_FIREBASE_ID_TOKEN, token) }

    fun accessToken(): String? = sp.getString(K_ACCESS, null)
    fun refreshToken(): String? = sp.getString(K_REFRESH, null)

    fun clearAll() = sp.edit { clear() }
}