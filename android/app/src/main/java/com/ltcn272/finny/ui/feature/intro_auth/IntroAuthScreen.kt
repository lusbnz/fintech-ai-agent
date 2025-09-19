package com.ltcn272.finny.ui.feature.intro_auth

import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import com.airbnb.lottie.compose.*
import com.facebook.CallbackManager
import com.ltcn272.finny.ui.components.PrimaryBackground
import com.ltcn272.finny.ui.feature.intro_auth.auth.AuthScreen
import com.ltcn272.finny.ui.feature.intro_auth.intro.IntroOne
import com.ltcn272.finny.ui.feature.intro_auth.intro.IntroTwo
import kotlinx.coroutines.delay

@Composable
fun IntroPage(
    scale: Float,
    alpha: Float,
    content: @Composable BoxScope.() -> Unit
) {
    Box(
        modifier = Modifier
            .graphicsLayer {
                this.scaleY = scale
                this.scaleX = scale
                this.alpha = alpha
            }
            .fillMaxSize(),
        contentAlignment = Alignment.Center,
        content = content
    )
}

@Composable
fun IndicatorDot(
    color: Color,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .size(9.dp)
            .clip(androidx.compose.foundation.shape.CircleShape)
            .background(color)
    )
}

@Composable
fun IntroAuthScreen(
    onDone: () -> Unit,
    callbackManager: CallbackManager
) {
    var showAuth by remember { mutableStateOf(false) }
    val pagerState = rememberPagerState(pageCount = { 2 })
    var showGuide by remember { mutableStateOf(false) }
    var lastInteraction by remember { mutableLongStateOf(System.currentTimeMillis()) }

    // Lottie composition
    val composition by rememberLottieComposition(LottieCompositionSpec.Asset("swipe_left.json"))
    val lottieAnimState = animateLottieCompositionAsState(
        composition,
        isPlaying = showGuide,
        iterations = LottieConstants.IterateForever
    )

    // Inactivity timer
    LaunchedEffect(lastInteraction) {
        showGuide = false
        delay(2500)
        if (System.currentTimeMillis() - lastInteraction >= 2500) {
            showGuide = true
        }
    }

    Crossfade(
        targetState = showAuth,
        animationSpec = tween(durationMillis = 1000, easing = FastOutSlowInEasing),
        label = "intro_auth_crossfade"
    ) { inAuth ->
        if (!inAuth) {
            // ======== INTRO ========
            PrimaryBackground(
                modifier = Modifier
                    .fillMaxSize()
                    .pointerInput(Unit) {
                        while (true) {
                            awaitPointerEventScope {
                                awaitPointerEvent()
                                lastInteraction = System.currentTimeMillis()
                                showGuide = false
                            }
                        }
                    }
            ) {
                Box(Modifier.fillMaxSize()) {
                    HorizontalPager(state = pagerState) { page ->
                        val pageOffset = (
                                (pagerState.currentPage - page) + pagerState.currentPageOffsetFraction
                                ).coerceIn(-1f, 1f)
                        val scale = 0.85f + (1 - kotlin.math.abs(pageOffset)) * 0.15f
                        val alpha = 0.5f + (1 - kotlin.math.abs(pageOffset)) * 0.5f

                        IntroPage(scale = scale, alpha = alpha) {
                            when (page) {
                                0 -> IntroOne()
                                1 -> IntroTwo(
                                    onGetStarted = { showAuth = true }
                                )
                            }
                        }
                    }

                    val showIndicator =
                        pagerState.currentPage + pagerState.currentPageOffsetFraction < 0.5f
                    if (showIndicator) {
                        Box(
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .padding(bottom = 40.dp)
                        ) {
                            DotIndicatorWithFade(pagerState = pagerState, pageCount = 2)
                        }
                    }

                    // Overlay Lottie guide (Intro 1)
                    val isOnIntro1 =
                        pagerState.currentPage == 0 && pagerState.currentPageOffsetFraction < 0.5f
                    if (showGuide && isOnIntro1) {
                        Box(
                            Modifier
                                .fillMaxSize()
                                .background(Color.Black.copy(alpha = 0.45f)),
                            contentAlignment = Alignment.Center
                        ) {
                            LottieAnimation(
                                composition = composition,
                                progress = { lottieAnimState.progress },
                                modifier = Modifier.size(180.dp)
                            )
                        }
                    }
                }
            }
        } else {
            // ======== AUTH ========
            PrimaryBackground(Modifier.fillMaxSize()) {
                AuthScreen(
                    onLoggedIn = { onDone() },
                    callbackManager = callbackManager
                )
            }
        }
    }
}

@Composable
fun DotIndicatorWithFade(
    pagerState: PagerState,
    pageCount: Int,
) {
    val dotSize = 9.dp
    val spacing = 16.dp

    val stepPx =
        with(androidx.compose.ui.platform.LocalDensity.current) { (dotSize + spacing).toPx() }
    val centerBias = (pageCount - 1) / 2f
    val progress = pagerState.currentPage + pagerState.currentPageOffsetFraction
    val tx = (progress - centerBias) * stepPx

    val alpha = 1f - pagerState.currentPageOffsetFraction.coerceIn(0f, 1f)

    Box(
        modifier = Modifier
            .wrapContentWidth()
            .graphicsLayer { this.alpha = alpha },
        contentAlignment = Alignment.Center
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(spacing)) {
            repeat(pageCount) {
                IndicatorDot(color = Color.Gray)
            }
        }

        IndicatorDot(
            color = Color.Black,
            modifier = Modifier.graphicsLayer { translationX = tx }
        )
    }
}
