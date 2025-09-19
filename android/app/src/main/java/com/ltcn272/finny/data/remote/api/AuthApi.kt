package com.ltcn272.finny.data.remote.api

import com.ltcn272.finny.data.remote.dto.LoginResponseDto
import com.ltcn272.finny.data.remote.dto.RefreshRequestDto
import com.ltcn272.finny.data.remote.dto.RefreshResponseDto
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST

interface AuthApi {
    @POST("auth/login") suspend fun login(): LoginResponseDto
    @POST("auth/refresh-token")
    suspend fun refresh(
        @Header("Authorization") authorization: String,
        @Body body: RefreshRequestDto
    ): RefreshResponseDto
}