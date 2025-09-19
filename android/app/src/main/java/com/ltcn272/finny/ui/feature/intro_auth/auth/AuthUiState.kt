package com.ltcn272.finny.ui.feature.intro_auth.auth

import com.ltcn272.finny.domain.model.AuthUser
import com.ltcn272.finny.domain.model.BackendSession

enum class AuthProvider {
    NONE, GOOGLE, FACEBOOK, APPLE
}

sealed class AuthUiState {
    data object Idle : AuthUiState()
    data class Loading(val provider: AuthProvider) : AuthUiState()
    data class Authorized(
        val firebaseUser: AuthUser?,
        val session: BackendSession
    ) : AuthUiState()
    data class Error(val message: String) : AuthUiState()
}