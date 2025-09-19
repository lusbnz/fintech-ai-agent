package com.ltcn272.finny.di

import com.google.firebase.auth.FirebaseAuth
import com.ltcn272.finny.data.auth.FirebaseAuthClient
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object FirebaseModule {
    @Provides
    @Singleton
    fun provideFirebaseAuth(): FirebaseAuth = FirebaseAuth.getInstance()
    @Provides
    @Singleton
    fun provideFirebaseClient(auth: FirebaseAuth) = FirebaseAuthClient(auth)
}

