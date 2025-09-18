package com.ltcn272.finny.ui.feature.intro

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.ltcn272.finny.R
import kotlinx.coroutines.launch


@Preview
@Composable
fun PreviewIntroTwo() {
    IntroTwo()
}

@Composable
fun IntroTwo(onGetStarted: () -> Unit = {}) {
    val scope = rememberCoroutineScope()
    val buttonHeight = 45.dp
    val iconBoxSize = 45.dp
    val minWidthPx = with(LocalDensity.current) { iconBoxSize.toPx() }
    val maxWidthPx = with(LocalDensity.current) { (LocalConfiguration.current.screenWidthDp.dp - 24.dp).toPx() }
    val buttonWidth = remember { Animatable(maxWidthPx) }
    var isAnimating by remember { mutableStateOf(false) }
    var animationDone by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        // Set initial width on first composition
        buttonWidth.snapTo(maxWidthPx)
    }

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
                            "2",
                            fontWeight = FontWeight.Black,
                            fontSize = 28.sp,
                            color = Color.Black
                        )
                        Text(
                            "Seconds to get an answer",
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
            "AI Assistant",
            fontWeight = FontWeight.Black,
            fontSize = 32.sp,
            color = Color.Black
        )
        Spacer(Modifier.height(20.dp))
        Text(
            "Your personal AI assistant, here to simplify your life. Whether you need help managing budget, AI is ready to assist you anytime, anywhere.",
            fontWeight = FontWeight.Medium,
            fontSize = 14.sp,
            color = Color.Black
        )
        Spacer(Modifier.weight(1f))
        Box(
            modifier = Modifier
                .width(with(LocalDensity.current) { buttonWidth.value.toDp() })
                .height(buttonHeight)
                .clip(RoundedCornerShape(20.dp))
                .background(Color.Black.copy(alpha = 0.7f))
                .clickable(enabled = !isAnimating && !animationDone) {
                    isAnimating = true
                    scope.launch {
                        buttonWidth.animateTo(
                            minWidthPx,
                            animationSpec = tween(durationMillis = 1000)
                        )
                        animationDone = true
                        onGetStarted()
                    }
                },
        ) {
            val iconOffset = if (isAnimating || animationDone) 0.dp else (with(LocalDensity.current) { buttonWidth.value.toDp() } - iconBoxSize)
            // Fade out text when animating
            val textAlpha by animateFloatAsState(
                targetValue = if (isAnimating) 0f else 1f,
                animationSpec = tween(durationMillis = 300), label = "textAlpha"
            )
            if (!animationDone && textAlpha > 0f) {
                Text(
                    "Get started now",
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    modifier = Modifier.align(Alignment.Center).graphicsLayer { alpha = textAlpha }
                )
            }
            Box(
                modifier = Modifier
                    .size(iconBoxSize)
                    .align(Alignment.CenterStart)
                    .offset(x = iconOffset)
                    .background(Color.Black.copy(alpha = 0.5f), shape = CircleShape)
                    .clip(CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_arrow_right),
                    contentDescription = null,
                    tint = Color.White
                )
            }
        }

        Spacer(Modifier.height(12.dp))
    }
}
