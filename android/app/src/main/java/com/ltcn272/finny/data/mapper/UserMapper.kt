package com.ltcn272.finny.data.mapper

import com.google.firebase.auth.FirebaseUser
import com.ltcn272.finny.domain.model.AuthUser

fun FirebaseUser.toDomain() = AuthUser(
    uid = uid,
    displayName = displayName,
    email = email,
    photoUrl = photoUrl?.toString()
)