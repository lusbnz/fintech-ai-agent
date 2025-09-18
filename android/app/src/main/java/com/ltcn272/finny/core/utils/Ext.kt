package com.ltcn272.finny.core.utils

import android.annotation.SuppressLint
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@SuppressLint("ConfigurationScreenWidthHeight")
@Composable
fun Float.toDpWidth(): Dp {
    val configuration = LocalConfiguration.current
    val screenWidthPx = configuration.screenWidthDp
    return (this * screenWidthPx).dp
}