package com.ltcn272.finny.ui.feature.intro_auth.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ltcn272.finny.domain.model.AuthUser
import com.ltcn272.finny.domain.usecase.auth.AuthUseCases
import com.ltcn272.finny.domain.usecase.auth.BackendLoginUseCase
import com.ltcn272.finny.domain.usecase.auth.GetIdTokenUseCase
import com.ltcn272.finny.domain.usecase.auth.SignInWithFacebookUseCase
import com.ltcn272.finny.domain.usecase.auth.SignInWithGoogleUseCase
import com.ltcn272.finny.domain.util.AppResult
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authUseCases: AuthUseCases
) : ViewModel() {

    // UI state
    private val _authState = MutableStateFlow<AuthUiState>(AuthUiState.Idle)
    val authState: StateFlow<AuthUiState> = _authState

    fun loginWithGoogle(idToken: String) {
        viewModelScope.launch {
            _authState.value = AuthUiState.Loading(AuthProvider.GOOGLE)
            when (val firebase = authUseCases.signInWithGoogle(idToken)) {
                is AppResult.Success -> {
                    handleBackendLogin(firebase.data)
                }
                is AppResult.Error -> _authState.value =
                    AuthUiState.Error("Google sign in failed: ${firebase.message}")
            }
        }
    }

    fun loginWithFacebook(accessToken: String) {
        viewModelScope.launch {
            _authState.value = AuthUiState.Loading(AuthProvider.FACEBOOK)
            when (val firebase = authUseCases.signInWithFacebook(accessToken)) {
                is AppResult.Success -> {
                    handleBackendLogin(firebase.data)
                }
                is AppResult.Error -> _authState.value =
                    AuthUiState.Error("Facebook sign in failed: ${firebase.message}")
            }
        }
    }

    private suspend fun handleBackendLogin(user: AuthUser) {
        when (val idToken = authUseCases.getIdToken(false)) {
            is AppResult.Success -> {
                when (val be = authUseCases.backendLogin()) {
                    is AppResult.Success -> {
                        _authState.value = AuthUiState.Authorized(
                            firebaseUser = user,
                            session = be.data
                        )
                    }
                    is AppResult.Error -> {
                        _authState.value = AuthUiState.Error("Backend login failed: ${be.message}")
                    }
                }
            }
            is AppResult.Error -> {
                _authState.value =
                    AuthUiState.Error("Cannot get Firebase ID token: ${idToken.message}")
            }
        }
    }
}
