package com.ltcn272.finny.domain.usecase.auth

data class AuthUseCases(
    val signInWithGoogle: SignInWithGoogleUseCase,
    val signInWithFacebook: SignInWithFacebookUseCase,
    val getIdToken: GetIdTokenUseCase,
    val backendLogin: BackendLoginUseCase,
    val refreshTokens: RefreshTokensUseCase
)