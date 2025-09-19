package com.ltcn272.finny.domain.model


data class AuthUser(
    val uid: String,
    val displayName: String?,
    val email: String?,
    val photoUrl: String?
)

data class BackendUser(
    val id: String,
    val displayName: String?,
    val email: String?,
    val avatar: String?,
    val plan: String?,
    val isActive: Boolean
)

data class Tokens(
    val accessToken: String,
    val refreshToken: String
)

data class BackendSession(
    val user: BackendUser,
    val tokens: Tokens
)