package com.ltcn272.finny.ui.feature.dashboard

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.ltcn272.finny.core.navigation.AppRoute

@Composable
fun DashboardScreen(
    onOpenTxn: (String) -> Unit, onOpenBudgets: (String) -> Unit = {},
    onOpenChat: (String) -> Unit = {},
    onOpenSettings: (String) -> Unit = {}
) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Button(onClick = { onOpenTxn("txn1") }) {
            Text("Open Transaction Detail")
        }
    }
}

