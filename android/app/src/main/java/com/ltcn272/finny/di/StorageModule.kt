package com.ltcn272.finny.di

import android.content.SharedPreferences
import com.ltcn272.finny.core.LoginStateManager
import com.ltcn272.finny.core.TokenManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object StorageModule {
    @Provides
    @Singleton
    fun provideSharedPreferences(app: android.app.Application): SharedPreferences =
        app.getSharedPreferences("finny_prefs", android.content.Context.MODE_PRIVATE)

    @Provides
    @Singleton
    fun provideTokenManager(sp: SharedPreferences) = TokenManager(sp)

    @Provides
    @Singleton
    fun provideLoginStateManager(sp: SharedPreferences) = LoginStateManager(sp)
}
