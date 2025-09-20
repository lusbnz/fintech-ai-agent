package com.ltcn272.finny.ui.feature.budget

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier

@Composable
fun BudgetListScreen(onOpenBudget: (String) -> Unit) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Button(onClick = { onOpenBudget("budget1") }) {
            Text("Open Budget Detail")
        }
    }
}

@Composable
fun BudgetDetailScreen(budgetId: String) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("Budget Detail: $budgetId")
    }
}

