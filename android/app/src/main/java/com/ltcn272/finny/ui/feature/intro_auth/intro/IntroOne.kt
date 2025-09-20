package com.ltcn272.finny.ui.feature.intro_auth.intro

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.ltcn272.finny.R
import com.ltcn272.finny.ui.feature.intro_auth.common.IntroHeader
import com.ltcn272.finny.ui.feature.intro_auth.common.IntroImageCard
import androidx.compose.foundation.layout.BoxWithConstraints

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
        IntroHeader(
            title = "Effortless,\nReal-Time Chats",
            subtitle = "With lightning-speed response times, it processes queries in real-time, offering clear and concise answers without delays."
        )
        Spacer(modifier = Modifier.fillMaxHeight().weight(1f))
        BoxWithConstraints(
            modifier = Modifier.fillMaxWidth()
        ) {
            val imageSize = maxWidth / 2
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Image(
                    painter = painterResource(R.drawable.intro_money),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .size(imageSize)
                        .clip(RoundedCornerShape(20.dp))
                )
                Image(
                    painter = painterResource(R.drawable.intro_money),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .size(imageSize)
                        .clip(RoundedCornerShape(20.dp))
                )
            }
        }
        Spacer(Modifier.height(8.dp))
        // Box ảnh lớn + card overlay dùng IntroImageCard
        IntroImageCard(
            image = painterResource(R.drawable.intro_hand),
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp),
            cardModifier = Modifier
                .padding(start = 4.dp, top = 8.dp, bottom = 40.dp),
            cardWidthFraction = 0.56f,
            cardHeightFraction = 1f,
            valueText = "1000 +",
            descriptionText = "Questions answered daily",
            icon = painterResource(R.drawable.ic_arrow_right)
        )
        Spacer(Modifier.height(40.dp))
    }
}