package com.ltcn272.finny.data.auth

import com.google.firebase.auth.FacebookAuthProvider
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import com.ltcn272.finny.data.mapper.toDomain
import com.ltcn272.finny.domain.model.AuthUser
import kotlinx.coroutines.tasks.await

class FirebaseAuthClient(private val auth: FirebaseAuth) {

    suspend fun signInWithGoogle(idToken: String): AuthUser {
        val cred = GoogleAuthProvider.getCredential(idToken, null)
        val user = auth.signInWithCredential(cred).await().user ?: error("No Firebase user")
        return user.toDomain()
    }

    suspend fun signInWithFacebook(accessToken: String): AuthUser {
        val cred = FacebookAuthProvider.getCredential(accessToken)
        val user = auth.signInWithCredential(cred).await().user ?: error("No Firebase user")
        return user.toDomain()
    }

    suspend fun fetchIdToken(forceRefresh: Boolean): String {
        val user = auth.currentUser ?: error("User not logged in")
        return user.getIdToken(forceRefresh).await().token ?: error("No ID token")
    }

    fun signOut() = auth.signOut()
}
