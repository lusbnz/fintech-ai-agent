package com.ltcn272.finny.data.repository

import com.ltcn272.finny.data.auth.FirebaseAuthClient
import com.ltcn272.finny.core.TokenManager
import com.ltcn272.finny.data.remote.api.AuthApi
import com.ltcn272.finny.data.remote.dto.RefreshRequestDto
import com.ltcn272.finny.domain.model.AuthUser
import com.ltcn272.finny.domain.model.BackendSession
import com.ltcn272.finny.domain.model.BackendUser
import com.ltcn272.finny.domain.model.Tokens
import com.ltcn272.finny.domain.repository.AuthRepository
import com.ltcn272.finny.domain.util.AppResult
import jakarta.inject.Inject


class AuthRepositoryImpl @Inject constructor(
    private val fb: FirebaseAuthClient,
    private val authApi: AuthApi,
    private val prefs: TokenManager
) : AuthRepository {

    // -------- Social -> Firebase --------
    override suspend fun signInWithGoogle(idToken: String): AppResult<AuthUser> =
        runCatching { fb.signInWithGoogle(idToken) }
            .fold(
                onSuccess = { AppResult.Success(it) },
                onFailure = { AppResult.Error(it.message ?: "Google sign-in failed", it) }
            )

    override suspend fun signInWithFacebook(accessToken: String): AppResult<AuthUser> =
        runCatching { fb.signInWithFacebook(accessToken) }
            .fold(
                onSuccess = { AppResult.Success(it) },
                onFailure = { AppResult.Error(it.message ?: "Facebook sign-in failed", it) }
            )

    // -------- Firebase ID token --------
    override suspend fun getFirebaseIdToken(forceRefresh: Boolean): AppResult<String> =
        runCatching { fb.fetchIdToken(forceRefresh) }
            .onSuccess { prefs.saveFirebaseIdToken(it) }
            .fold(
                onSuccess = { AppResult.Success(it) },
                onFailure = { AppResult.Error(it.message ?: "Get Firebase ID token failed", it) }
            )

    // -------- Backend login (Bearer: Firebase ID token) --------
    override suspend fun backendLogin(): AppResult<BackendSession> =
        runCatching {
            val data = authApi.login().data
            // Lưu access/refresh vào SharedPrefs
            prefs.saveAccessToken(data.accessToken)
            prefs.saveRefreshToken(data.refreshToken)

            BackendSession(
                user = BackendUser(
                    id = data.user.id,
                    displayName = data.user.displayName,
                    email = data.user.email,
                    avatar = data.user.avatar,
                    plan = data.user.plan,
                    isActive = data.user.isActive
                ),
                tokens = Tokens(
                    accessToken = data.accessToken,
                    refreshToken = data.refreshToken
                )
            )
        }.fold(
            onSuccess = { AppResult.Success(it) },
            onFailure = { AppResult.Error(it.message ?: "Backend login failed", it) }
        )

    // -------- Refresh tokens (Bearer: access_token hiện tại) --------
    override suspend fun refreshTokens(): AppResult<Tokens> =
        runCatching {
            val refresh = prefs.refreshToken() ?: error("No refresh token")
            val staleAccess = prefs.accessToken().orEmpty()
            val resp = authApi.refresh(
                authorization = "Bearer $staleAccess",
                body = RefreshRequestDto(refresh)
            ).data

            // Cập nhật cache
            prefs.saveAccessToken(resp.accessToken)
            prefs.saveRefreshToken(resp.refreshToken)

            Tokens(
                accessToken = resp.accessToken,
                refreshToken = resp.refreshToken
            )
        }.fold(
            onSuccess = { AppResult.Success(it) },
            onFailure = { AppResult.Error(it.message ?: "Refresh failed", it) }
        )

    // -------- Session helpers --------
    override fun currentAccessToken(): String? = prefs.accessToken()
    override fun currentRefreshToken(): String? = prefs.refreshToken()

    override suspend fun signOut() {
        fb.signOut()
        prefs.clearAll()
    }
}
