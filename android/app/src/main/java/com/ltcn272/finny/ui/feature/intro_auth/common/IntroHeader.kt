package com.ltcn272.finny.ui.feature.intro_auth.common

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale

@Composable
fun IntroHeader(
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier,
    titleStyle: TextStyle = TextStyle(fontWeight = FontWeight.Black, fontSize = 38.sp, color = Color.Black, lineHeight = 44.sp),
    subtitleStyle: TextStyle = TextStyle(fontWeight = FontWeight.Medium, fontSize = 14.sp, color = Color.Black, lineHeight = 20.sp),
    space: Dp = 20.dp,
    enableAnimation: Boolean = true
) {
    var visible by remember { mutableStateOf(!enableAnimation) }
    LaunchedEffect(enableAnimation) {
        if (enableAnimation) {
            visible = true
        }
    }
    val alpha by animateFloatAsState(
        targetValue = if (visible) 1f else 0f,
        animationSpec = tween(durationMillis = 1200, easing = FastOutSlowInEasing), label = "header_alpha"
    )
    val scale by animateFloatAsState(
        targetValue = if (visible) 1f else 0.95f,
        animationSpec = tween(durationMillis = 1200, easing = FastOutSlowInEasing), label = "header_scale"
    )
    Column(
        modifier = modifier
            .alpha(alpha)
            .scale(scale)
    ) {
        Text(
            text = title,
            style = titleStyle
        )
        Spacer(Modifier.height(space))
        Text(
            text = subtitle,
            style = subtitleStyle
        )
    }
}
