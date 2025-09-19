@file:Suppress("PackageDirectoryMismatch")

package com.ltcn272.finny.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import com.ltcn272.finny.ui.theme.PrimaryBackgroundEnd
import com.ltcn272.finny.ui.theme.PrimaryBackgroundStart

@Composable
fun PrimaryBackground(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.linearGradient(
                    colors = listOf(
                        PrimaryBackgroundStart.copy(alpha = 0.2f),
                        PrimaryBackgroundEnd.copy(alpha = 0.2f)
                    ),
                    start = Offset(0f, 0f),
                    end = Offset(0f, Float.POSITIVE_INFINITY)
                )
            )
    ) {
        Box(modifier = modifier) {
            content()
        }
    }
}
