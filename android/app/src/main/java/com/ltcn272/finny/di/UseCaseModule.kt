package com.ltcn272.finny.di

import com.ltcn272.finny.domain.repository.AuthRepository
import com.ltcn272.finny.domain.usecase.auth.AuthUseCases
import com.ltcn272.finny.domain.usecase.auth.BackendLoginUseCase
import com.ltcn272.finny.domain.usecase.auth.GetIdTokenUseCase
import com.ltcn272.finny.domain.usecase.auth.RefreshTokensUseCase
import com.ltcn272.finny.domain.usecase.auth.SignInWithFacebookUseCase
import com.ltcn272.finny.domain.usecase.auth.SignInWithGoogleUseCase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object UseCaseModule {

    @Provides
    @Singleton
    fun provideAuthUseCases(
        repo: AuthRepository
    ): AuthUseCases {
        return AuthUseCases(
            signInWithGoogle = SignInWithGoogleUseCase(repo),
            signInWithFacebook = SignInWithFacebookUseCase(repo),
            getIdToken = GetIdTokenUseCase(repo),
            backendLogin = BackendLoginUseCase(repo),
            refreshTokens = RefreshTokensUseCase(repo)
        )
    }
}