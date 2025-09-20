package com.ltcn272.finny.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Qualifier
import jakarta.inject.Singleton

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class BaseUrl

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides @Singleton @BaseUrl
    fun provideBaseUrl(): String = "https://qlct.vercel.app/api/v1/"
}

