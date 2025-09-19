package com.ltcn272.finny.data.remote.dto

import com.google.gson.annotations.SerializedName

data class LoginResponseDto(
    @SerializedName("data") val data: LoginDataDto
)

data class LoginDataDto(
    @SerializedName("user") val user: BackendUserDto,
    @SerializedName("access_token") val accessToken: String,
    @SerializedName("refresh_token") val refreshToken: String
)

data class BackendUserDto(
    @SerializedName("_id") val id: String,
    @SerializedName("display_name") val displayName: String?,
    @SerializedName("email") val email: String?,
    @SerializedName("avatar") val avatar: String?,
    @SerializedName("plan") val plan: String?,
    @SerializedName("is_active") val isActive: Boolean
)

data class RefreshRequestDto(
    @SerializedName("refresh_token") val refreshToken: String
)

data class RefreshResponseDto(
    @SerializedName("data") val data: RefreshDataDto
)

data class RefreshDataDto(
    @SerializedName("access_token") val accessToken: String,
    @SerializedName("refresh_token") val refreshToken: String
)