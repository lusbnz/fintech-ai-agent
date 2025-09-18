package com.ltcn272.finny.ui.feature.intro

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import com.airbnb.lottie.compose.*
import com.ltcn272.finny.ui.components.PrimaryBackground
import kotlinx.coroutines.delay

@Composable
fun IntroScreen(
    onGetStarted: () -> Unit = {}
) {
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
                Box(
                    modifier = Modifier
                        .graphicsLayer {
                            this.scaleY = scale
                            this.scaleX = scale
                            this.alpha = alpha
                        }
                        .fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    when (page) {
                        0 -> IntroOne()
                        1 -> IntroTwo(onGetStarted = onGetStarted)
                    }
                }
            }
            val showIndicator = pagerState.currentPage + pagerState.currentPageOffsetFraction < 0.5f
            if (showIndicator) {
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(bottom = 40.dp)
                ) {
                    DotIndicatorWithFade(pagerState = pagerState, pageCount = 2)
                }
            }
            // Overlay Lottie guide if needed (only on Intro 1)
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
}

@Composable
private fun DotIndicatorWithFade(
    pagerState: androidx.compose.foundation.pager.PagerState,
    pageCount: Int,
) {
    val dotSize = 9.dp
    val spacing = 16.dp

    val stepPx = with(LocalDensity.current) { (dotSize + spacing).toPx() }
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
                Box(
                    Modifier
                        .size(dotSize)
                        .clip(CircleShape)
                        .background(Color.Gray)
                )
            }
        }

        Box(
            Modifier
                .size(dotSize)
                .graphicsLayer { translationX = tx }
                .clip(CircleShape)
                .background(Color.Black)
        )
    }
}
