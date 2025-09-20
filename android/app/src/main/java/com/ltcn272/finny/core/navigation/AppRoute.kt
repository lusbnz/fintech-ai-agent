package com.ltcn272.finny.core.navigation

import android.net.Uri
import androidx.navigation.NavHostController

sealed class AppRoute(val route: String) {
    // Auth
    data object Auth : AppRoute("auth")
    data object IntroAuth : AppRoute("intro_auth")
    // Main
    data object Dashboard : AppRoute("dashboard")
    data object Timeline : AppRoute("timeline")
    data object CreateTransaction : AppRoute("txn_create")
    data object TransactionDetail : AppRoute("txn_detail/{id}") {
        fun createRoute(id: String) = "txn_detail/${Uri.encode(id)}"
    }
    data object BudgetList : AppRoute("budget_list")
    data object BudgetDetail : AppRoute("budget_detail/{id}") {
        fun createRoute(id: String) = "budget_detail/${Uri.encode(id)}"
    }
    data object Chat : AppRoute("chat")
    data object Settings : AppRoute("settings")
    data object Upsell : AppRoute("upsell")
}

fun NavHostController.navigateSingleTop(route: String, popTo: String? = null, inclusive: Boolean = false) {
    navigate(route) {
        launchSingleTop = true
        restoreState = true
        if (popTo != null) popUpTo(popTo) { this.inclusive = inclusive; saveState = true }
    }
}
