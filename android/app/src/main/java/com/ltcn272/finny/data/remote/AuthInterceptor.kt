package com.ltcn272.finny.data.remote

import com.google.firebase.auth.FirebaseAuth
import com.ltcn272.finny.core.TokenManager
import com.ltcn272.finny.data.remote.api.AuthApi
import com.ltcn272.finny.data.remote.dto.RefreshRequestDto
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.tasks.await
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class AuthInterceptor(
    private val firebaseAuth: FirebaseAuth,
    private val prefs: TokenManager,
    private val baseUrl: String
) : Interceptor {

    @Volatile
    private var isRefreshing = false

    override fun intercept(chain: Interceptor.Chain): Response {
        var req = chain.request()
        val path = req.url.encodedPath

        val bearer = runBlocking {
            when {
                path.endsWith("/auth/login") -> {
                    val token = try {
                        firebaseAuth.currentUser?.getIdToken(false)?.await()?.token
                    } catch (_: Exception) {
                        null
                    }
                    token?.also { prefs.saveFirebaseIdToken(it) }
                }

                else -> prefs.accessToken()
            }
        }

        if (!bearer.isNullOrBlank()) {
            req = req.newBuilder()
                .header("Authorization", "Bearer $bearer")
                .build()
        }

        val res = chain.proceed(req)

        if (res.code == 401 && !path.endsWith("/auth/login")) {
            synchronized(this) {
                if (!isRefreshing) {
                    isRefreshing = true
                    try {
                        runBlocking { refreshNow() }
                    } finally {
                        isRefreshing = false
                    }
                }
            }
            res.close()
            val retried = req.newBuilder()
                .header("Authorization", "Bearer ${prefs.accessToken().orEmpty()}")
                .build()
            return chain.proceed(retried)
        }

        return res
    }

    private suspend fun refreshNow() {
        val refresh = prefs.refreshToken() ?: return
        val staleAccess = prefs.accessToken().orEmpty()

        val ok = OkHttpClient.Builder().build()
        val api = Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(ok)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(AuthApi::class.java)

        runCatching {
            val resp = api.refresh("Bearer $staleAccess", RefreshRequestDto(refresh))
            prefs.saveAccessToken(resp.data.accessToken)
            prefs.saveRefreshToken(resp.data.refreshToken)
        }
    }
}