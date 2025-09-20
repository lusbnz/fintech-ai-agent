package com.ltcn272.finny.di

import com.google.firebase.auth.FirebaseAuth
import com.ltcn272.finny.core.TokenManager
import com.ltcn272.finny.data.remote.AuthInterceptor
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import jakarta.inject.Singleton
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory


@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttp(
        firebaseAuth: FirebaseAuth,
        prefs: TokenManager,
        @BaseUrl baseUrl: String
    ): OkHttpClient = OkHttpClient.Builder()
        .addInterceptor(AuthInterceptor(firebaseAuth, prefs, baseUrl))
        .build()

    @Provides
    @Singleton
    fun provideRetrofit(
        okHttp: OkHttpClient,
        @BaseUrl baseUrl: String
    ): Retrofit = Retrofit.Builder()
        .baseUrl(baseUrl)
        .client(okHttp)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
}
