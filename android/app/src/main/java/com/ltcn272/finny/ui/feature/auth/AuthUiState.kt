package com.ltcn272.finny.ui.feature.auth

import com.ltcn272.finny.domain.model.AuthUser
import com.ltcn272.finny.domain.model.BackendSession

sealed class AuthUiState {
    data object Idle : AuthUiState()
    data object Loading : AuthUiState()
    data class Authorized(
        val firebaseUser: AuthUser?,
        val session: BackendSession
    ) : AuthUiState()
    data class Error(val message: String) : AuthUiState()
}