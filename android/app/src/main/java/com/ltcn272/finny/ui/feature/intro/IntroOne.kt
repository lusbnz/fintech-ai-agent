package com.ltcn272.finny.ui.feature.intro

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.ltcn272.finny.R

@Preview
@Composable
fun PreviewIntroOne() {
    IntroOne()
}

@Composable
fun IntroOne() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 12.dp)
            .padding(bottom = 40.dp),
        verticalArrangement = Arrangement.Top
    ) {
        Spacer(Modifier.height(48.dp))

        // Text phần đầu
        Text(
            "Effortless,\nReal-Time Chats",
            fontWeight = FontWeight.Black,
            fontSize = 38.sp,
            color = Color.Black,
            lineHeight = 44.sp
        )
        Spacer(Modifier.height(20.dp))
        Text(
            "With lightning-speed response times, it processes queries in real-time, offering clear and concise answers without delays.",
            fontWeight = FontWeight.Medium,
            fontSize = 14.sp,
            color = Color.Black,
            lineHeight = 20.sp
        )

        // Đẩy phần ảnh xuống cuối
        Spacer(modifier = Modifier.weight(1f))

        // PHẦN ẢNH
        Column(
            modifier = Modifier.fillMaxWidth()
        ) {
            // 2 ảnh nhỏ
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Image(
                    painter = painterResource(R.drawable.intro_money),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .clip(RoundedCornerShape(20.dp))
                )
                Image(
                    painter = painterResource(R.drawable.intro_money),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .clip(RoundedCornerShape(20.dp))
                )
            }

            Spacer(Modifier.height(8.dp))

            // Ảnh lớn + card overlay
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp)
            ) {
                Image(
                    painter = painterResource(R.drawable.intro_hand),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(28.dp))
                )
                Card(
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .padding(start = 4.dp, top = 8.dp, bottom = 40.dp)
                        .fillMaxWidth(0.56f)
                        .fillMaxHeight(),
                    shape = RoundedCornerShape(28.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(8.dp)
                ) {
                    Box(Modifier.fillMaxSize()) {
                        Column(
                            Modifier
                                .align(Alignment.TopStart)
                                .padding(20.dp)
                        ) {
                            Text(
                                "1000 +",
                                fontWeight = FontWeight.Black,
                                fontSize = 24.sp,
                                color = Color.Black
                            )
                            Text(
                                "Questions\nanswered daily",
                                fontWeight = FontWeight.Medium,
                                fontSize = 12.sp,
                                color = Color.Black
                            )
                        }
                        Box(
                            modifier = Modifier
                                .align(Alignment.BottomEnd)
                                .padding(16.dp)
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
            Spacer(Modifier.height(40.dp))
        }
    }
}