package com.ltcn272.finny.domain.usecase.auth

import com.ltcn272.finny.domain.repository.AuthRepository

class BackendLoginUseCase(private val repo: AuthRepository) {
    suspend operator fun invoke() = repo.backendLogin()
}