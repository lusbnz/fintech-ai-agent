package com.ltcn272.finny.ui.feature.intro_auth.common

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Preview
@Composable
fun IntroImageCardPreview() {
    IntroImageCard(
        image = painterResource(id = com.ltcn272.finny.R.drawable.intro_hand),
        modifier = Modifier
            .fillMaxWidth()
            .height(300.dp)
            .padding(16.dp),
        valueText = "Effortless,\nReal-Time Chats",
        descriptionText = "With lightning-speed response times, it processes queries in real-time, offering clear and concise answers without delays.",
        icon = painterResource(id = com.ltcn272.finny.R.drawable.ic_arrow_right)
    )
}

@Composable
fun IntroImageCard(
    image: Painter,
    modifier: Modifier = Modifier,
    imageShape: RoundedCornerShape = RoundedCornerShape(28.dp),
    cardModifier: Modifier = Modifier,
    cardShape: RoundedCornerShape = RoundedCornerShape(28.dp),
    cardColor: Color = Color.White,
    cardElevation: Dp = 16.dp,
    valueText: String? = null,
    descriptionText: String? = null,
    valueStyle: TextStyle = TextStyle(
        fontWeight = FontWeight.Black,
        fontSize = 24.sp,
        color = Color.Black
    ),
    descriptionStyle: TextStyle = TextStyle(
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        color = Color.Black
    ),
    icon: Painter? = null,
    iconTint: Color = Color.White,
    iconBg: Color = Color(0xFF444444),
    iconModifier: Modifier = Modifier,
    iconBoxModifier: Modifier = Modifier,
    iconSize: Dp = 45.dp,
    cardAlign: Alignment = Alignment.TopStart,
    cardWidthFraction: Float = 0.56f,
    cardHeightFraction: Float = 1f
) {
    Box(modifier = modifier) {
        Image(
            painter = image,
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .fillMaxSize()
                .clip(imageShape)
        )
        Card(
            modifier = cardModifier
                .align(cardAlign)
                .fillMaxWidth(cardWidthFraction)
                .fillMaxHeight(cardHeightFraction),
            shape = cardShape,
            colors = CardDefaults.cardColors(containerColor = cardColor),
            elevation = CardDefaults.cardElevation(cardElevation),
            border = BorderStroke(20.dp, Color.White.copy(alpha = 0.5f))
        ) {
            Box(Modifier.fillMaxSize()) {
                if (valueText != null && descriptionText != null) {
                    Column(
                        modifier = Modifier.padding(
                            start = 20.dp,
                            top = 20.dp,
                            end = iconSize + 20.dp,
                            bottom = 20.dp
                        )
                    ) {
                        Text(
                            valueText,
                            style = valueStyle
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            descriptionText,
                            style = descriptionStyle
                        )
                    }
                }
                if (icon != null) {
                    Box(
                        modifier = iconBoxModifier
                            .align(Alignment.BottomEnd)
                            .padding(16.dp)
                            .size(iconSize)
                            .background(iconBg, shape = CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            painter = icon,
                            contentDescription = null,
                            tint = iconTint,
                            modifier = iconModifier
                        )
                    }
                }
            }
        }
    }
}


