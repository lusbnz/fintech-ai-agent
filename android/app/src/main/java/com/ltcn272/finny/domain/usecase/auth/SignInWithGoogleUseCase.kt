package com.ltcn272.finny.domain.usecase.auth

import com.ltcn272.finny.domain.repository.AuthRepository


class SignInWithGoogleUseCase(
    private val repo: AuthRepository
) {
    suspend operator fun invoke(idToken: String) = repo.signInWithGoogle(idToken)
}