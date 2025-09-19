package com.ltcn272.finny.domain.usecase.auth

import com.ltcn272.finny.domain.repository.AuthRepository

class SignInWithFacebookUseCase(private val repo: AuthRepository) {
    suspend operator fun invoke(accessToken: String) = repo.signInWithFacebook(accessToken)
}