package com.ltcn272.finny.ui.feature.intro_auth.auth

import android.app.Activity
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
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
import com.ltcn272.finny.ui.feature.intro_auth.common.IntroHeader
import com.ltcn272.finny.ui.feature.intro_auth.common.IntroImageCard
import com.ltcn272.finny.ui.feature.intro_auth.common.LoginButton
import kotlinx.coroutines.CoroutineScope


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

    // Facebook callback đăng nhập
    DisposableEffect(Unit) {
        val callback = object : FacebookCallback<LoginResult> {
            override fun onSuccess(result: LoginResult) {
                viewModel.loginWithFacebook(result.accessToken.token)
            }

            override fun onCancel() {}
            override fun onError(error: FacebookException) {
                Toast.makeText(
                    context,
                    "Facebook login error: ${error.message}",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
        LoginManager.getInstance().registerCallback(callbackManager, callback)
        onDispose { LoginManager.getInstance().unregisterCallback(callbackManager) }
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
            IntroImageCard(
                image = painterResource(R.drawable.intro_2_money),
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.6f),
                cardModifier = Modifier
                    .padding(top = 12.dp, start = 8.dp),
                cardWidthFraction = 0.55f,
                cardHeightFraction = 0.35f,
                valueText = "5000+",
                descriptionText = "Daily users",
                icon = painterResource(R.drawable.ic_arrow_right)
            )
            Spacer(Modifier.height(12.dp))
            IntroHeader(
                title = "Login the Finny!",
                subtitle = "Login to your account to see your progress and routes.",
                titleStyle = androidx.compose.ui.text.TextStyle(
                    fontWeight = FontWeight.Black,
                    fontSize = 32.sp,
                    color = Color.Black
                ),
                space = 20.dp
            )
            Spacer(modifier = Modifier
                .fillMaxHeight()
                .weight(1f))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 40.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterHorizontally)
            ) {
                LoginButton(
                    backgroundColor = Color.Black,
                    icon = painterResource(R.drawable.ic_apple),
                    iconTint = Color.White,
                    onClick = { /* TODO: Apple login */ },
                    modifier = Modifier.weight(1f),
                    contentDescription = "Apple"
                )
                LoginButton(
                    backgroundColor = Color.White,
                    icon = painterResource(R.drawable.ic_google),
                    iconTint = Color.Unspecified,
                    onClick = { handleGoogleLogin(context, viewModel, scope) },
                    modifier = Modifier.weight(1f),
                    contentDescription = "Google"
                )
                LoginButton(
                    backgroundColor = Color(0xFF1877F3),
                    icon = painterResource(R.drawable.ic_facebook),
                    iconTint = Color.White,
                    onClick = { handleFacebookLogin(activity) },
                    modifier = Modifier.weight(1f),
                    contentDescription = "Facebook"
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
        val authProvider = (authUiState as AuthUiState.Loading).provider
        val lottieAnimationFile = when (authProvider) {
            AuthProvider.GOOGLE -> "google_loading.json"
            AuthProvider.FACEBOOK -> "facebook_loading.json"
            AuthProvider.NONE, AuthProvider.APPLE -> ""
        }
        val composition by rememberLottieComposition(LottieCompositionSpec.Asset(lottieAnimationFile))
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

private fun handleGoogleLogin(context: Context, viewModel: AuthViewModel, scope: CoroutineScope) {
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
            val result: GetCredentialResponse = credentialManager.getCredential(context, request)
            handleSignInResult(result, viewModel, context)
        } catch (e: Exception) {
            Toast.makeText(context, "Google SignIn error: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
}

private fun handleFacebookLogin(activity: Activity?) {
    activity?.let {
        LoginManager.getInstance().logInWithReadPermissions(
            it,
            listOf("public_profile", "email")
        )
    }
}

private fun handleSignInResult(
    result: GetCredentialResponse,
    viewModel: AuthViewModel,
    context: Context
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

@Preview
@Composable
fun AuthScreenPreview() {
    PrimaryBackground {
        AuthScreen(
            onLoggedIn = {},
            callbackManager = CallbackManager.Factory.create()
        )
    }
}
