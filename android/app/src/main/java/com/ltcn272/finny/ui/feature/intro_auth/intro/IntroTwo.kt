package com.ltcn272.finny.ui.feature.intro_auth.intro

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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.ltcn272.finny.R
import com.ltcn272.finny.ui.feature.intro_auth.common.IntroHeader
import com.ltcn272.finny.ui.feature.intro_auth.common.IntroImageCard


@Composable
fun IntroTwo(
    onGetStarted: () -> Unit = {}
) {
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
            valueText = "2",
            descriptionText = "Seconds to get an answer",
            icon = painterResource(R.drawable.ic_arrow_right)
        )
        Spacer(Modifier.height(12.dp))
        IntroHeader(
            title = "AI Assistant",
            subtitle = "Your personal AI assistant, here to simplify your life. Whether you need help managing budget, AI is ready to assist you anytime, anywhere.",
            titleStyle = androidx.compose.ui.text.TextStyle(fontWeight = FontWeight.Black, fontSize = 32.sp, color = Color.Black),
            space = 20.dp
        )
        Spacer(modifier = Modifier.fillMaxHeight().weight(1f))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(45.dp)
                .clip(RoundedCornerShape(20.dp))
                .background(Color.Black.copy(alpha = 0.7f))
                .clickable { onGetStarted() },
            contentAlignment = Alignment.Center
        ) {
            Text(
                "Get started now",
                color = Color.White,
                fontWeight = FontWeight.Bold,
                fontSize = 14.sp
            )
            Box(
                modifier = Modifier
                    .size(45.dp)
                    .align(Alignment.CenterEnd)
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

@Preview
@Composable
fun IntroTwoPreview() {
    IntroTwo()
}