package com.ltcn272.finny.domain.repository

import com.ltcn272.finny.domain.model.AuthUser
import com.ltcn272.finny.domain.model.BackendSession
import com.ltcn272.finny.domain.model.Tokens
import com.ltcn272.finny.domain.util.AppResult

interface AuthRepository {
    // Social -> Firebase
    suspend fun signInWithGoogle(idToken: String): AppResult<AuthUser>
    suspend fun signInWithFacebook(accessToken: String): AppResult<AuthUser>

    // Firebase ID token
    suspend fun getFirebaseIdToken(forceRefresh: Boolean = false): AppResult<String>

    // Backend
    suspend fun backendLogin(): AppResult<BackendSession>
    suspend fun refreshTokens(): AppResult<Tokens>

    // Session
    fun currentAccessToken(): String?
    fun currentRefreshToken(): String?
    suspend fun signOut()
}