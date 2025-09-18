package com.ltcn272.finny.ui.feature.auth

import android.app.Activity
import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.ltcn272.finny.R
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.Credential
import androidx.credentials.CustomCredential
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.ltcn272.finny.ui.components.PrimaryBackground
import com.airbnb.lottie.compose.*
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import kotlinx.coroutines.launch


@Composable
fun AuthScreen(
    viewModel: AuthViewModel = hiltViewModel(),
    onLoggedIn: () -> Unit = {},
    callbackManager: CallbackManager
) {
    val authUiState by viewModel.authState.collectAsState()
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val activity = context as? Activity

    // Register Facebook callback
    DisposableEffect(Unit) {
        val callback = object : FacebookCallback<LoginResult> {
            override fun onSuccess(result: LoginResult) {
                val accessToken = result.accessToken.token
                viewModel.loginWithFacebook(accessToken)
            }
            override fun onCancel() {}
            override fun onError(error: FacebookException) {
                Toast.makeText(context, "Facebook login error: ${error.message}", Toast.LENGTH_SHORT).show()
            }
        }
        LoginManager.getInstance().registerCallback(callbackManager, callback)
        onDispose {
            LoginManager.getInstance().unregisterCallback(callbackManager)
        }
    }

    PrimaryBackground {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 12.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.Top
        ) {
            Spacer(Modifier.height(48.dp))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.6f)
            ) {
                Image(
                    painter = painterResource(R.drawable.intro_2_money),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(30.dp))
                )
                Card(
                    modifier = Modifier
                        .padding(top = 12.dp, start = 8.dp)
                        .align(Alignment.TopStart)
                        .fillMaxWidth(0.55f)
                        .fillMaxHeight(0.35f),
                    shape = RoundedCornerShape(28.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(8.dp)
                ) {
                    Box(Modifier.fillMaxSize()) {
                        Column(
                            Modifier
                                .align(Alignment.TopStart)
                                .padding(20.dp),
                            verticalArrangement = Arrangement.Center
                        ) {
                            Text(
                                "5000+",
                                fontWeight = FontWeight.Black,
                                fontSize = 28.sp,
                                color = Color.Black
                            )
                            Text(
                                "Daily users",
                                fontWeight = FontWeight.Medium,
                                fontSize = 16.sp,
                                color = Color.Black
                            )
                        }
                        Box(
                            modifier = Modifier
                                .align(Alignment.BottomEnd)
                                .padding(12.dp)
                                .size(40.dp)
                                .clip(CircleShape)
                                .background(Color(0xFF444444)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                painter = painterResource(R.drawable.ic_arrow_right),
                                contentDescription = null,
                                tint = Color.White
                            )
                        }
                    }
                }
            }
            Spacer(Modifier.height(12.dp))
            Text(
                "Login the Finny!",
                fontWeight = FontWeight.Black,
                fontSize = 32.sp,
                color = Color.Black
            )
            Spacer(Modifier.height(20.dp))
            Text(
                "Login to your account to see your progress and routes.",
                fontWeight = FontWeight.Medium,
                fontSize = 14.sp,
                color = Color.Black
            )
            Spacer(Modifier.weight(1f))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 40.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterHorizontally)
            ) {
                Box(
                    modifier = Modifier
                        .height(45.dp)
                        .weight(1f)
                        .clip(RoundedCornerShape(26.dp))
                        .background(Color.Black)
                        .clickable { /* TODO: Apple login */ },
                ) {
                    Icon(
                        painter = painterResource(R.drawable.ic_apple),
                        contentDescription = "Apple",
                        tint = Color.White,
                        modifier = Modifier
                            .size(20.dp)
                            .align(Alignment.Center)
                    )
                }
                Box(
                    modifier = Modifier
                        .height(45.dp)
                        .weight(1f)
                        .clip(RoundedCornerShape(26.dp))
                        .background(Color.White)
                        .clickable {
                            scope.launch {
                                try {
                                    val credentialManager = CredentialManager.create(context)

                                    val googleIdOption = GetGoogleIdOption.Builder()
                                        .setFilterByAuthorizedAccounts(false)
                                        .setServerClientId(context.getString(R.string.default_web_client_id))
                                        .build()

                                    val request = GetCredentialRequest.Builder()
                                        .addCredentialOption(googleIdOption)
                                        .build()

                                    val result: GetCredentialResponse =
                                        credentialManager.getCredential(context, request)

                                    handleSignInResult(result, viewModel, context)
                                } catch (e: Exception) {
                                    Toast.makeText(
                                        context,
                                        "Google SignIn error: ${e.message}",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                            }
                        },
                ) {
                    Icon(
                        painter = painterResource(R.drawable.ic_google),
                        contentDescription = "Google",
                        tint = Color.Unspecified,
                        modifier = Modifier
                            .size(20.dp)
                            .align(Alignment.Center)
                    )
                }
                Box(
                    modifier = Modifier
                        .height(45.dp)
                        .weight(1f)
                        .clip(RoundedCornerShape(26.dp))
                        .background(Color(0xFF1877F3))
                        .clickable {
                            activity?.let {
                                LoginManager.getInstance().logInWithReadPermissions(
                                    it,
                                    listOf("public_profile")
                                )
                            }
                        }
                ) {
                    Icon(
                        painter = painterResource(R.drawable.ic_facebook),
                        contentDescription = "Facebook",
                        tint = Color.White,
                        modifier = Modifier
                            .size(20.dp)
                            .align(Alignment.Center)
                    )
                }
            }

            Spacer(Modifier.height(12.dp))

            LaunchedEffect(authUiState) {
                when (authUiState) {
                    is AuthUiState.Authorized -> {
                        val user = (authUiState as AuthUiState.Authorized).firebaseUser
                        Toast.makeText(context, "Xin chào ${user?.displayName}", Toast.LENGTH_LONG)
                            .show()
                        onLoggedIn()
                    }

                    is AuthUiState.Error -> {
                        val errorMsg = (authUiState as AuthUiState.Error).message
                        Toast.makeText(context, errorMsg, Toast.LENGTH_LONG).show()
                    }

                    else -> {}
                }
            }
        }
        if (authUiState is AuthUiState.Loading) {
            val composition by rememberLottieComposition(LottieCompositionSpec.Asset("google_loading.json"))
            val progress by animateLottieCompositionAsState(
                composition = composition,
                iterations = LottieConstants.IterateForever
            )
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color(0x88000000)),
                contentAlignment = Alignment.Center
            ) {
                LottieAnimation(
                    composition = composition,
                    progress = { progress },
                    modifier = Modifier.size(80.dp)
                )
            }
        }
    }
}

private fun handleSignInResult(
    result: GetCredentialResponse,
    viewModel: AuthViewModel,
    context: android.content.Context
) {
    val credential: Credential = result.credential
    if (credential is CustomCredential &&
        credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
    ) {
        try {
            val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(credential.data)
            val idToken = googleIdTokenCredential.idToken
            viewModel.loginWithGoogle(idToken)
        } catch (e: Exception) {
            Toast.makeText(context, "Invalid Google credential: ${e.message}", Toast.LENGTH_SHORT)
                .show()
        }
    }
}
