package com.ltcn272.finny.core.navigation

import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import androidx.navigation.NavType
import com.ltcn272.finny.ui.feature.dashboard.DashboardScreen
import com.ltcn272.finny.ui.feature.timeline.TimelineScreen
import com.ltcn272.finny.ui.feature.transaction.TransactionDetailScreen
import com.ltcn272.finny.ui.feature.transaction.CreateTransactionScreen
import com.ltcn272.finny.ui.feature.budget.BudgetListScreen
import com.ltcn272.finny.ui.feature.budget.BudgetDetailScreen
import com.ltcn272.finny.ui.feature.chat.ChatScreen
import com.ltcn272.finny.ui.feature.settings.SettingsScreen
import com.ltcn272.finny.ui.feature.upsell.UpsellScreen
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.navigation.compose.rememberNavController
import com.ltcn272.finny.ui.feature.intro_auth.IntroAuthScreen
import com.facebook.CallbackManager

@Composable
fun AppNavHost(
    navController: NavHostController = rememberNavController(),
    callbackManager: CallbackManager
) {
    val managers = hiltViewModel<ManagerProviderViewModel>()
    val loginStateManager = managers.loginStateManager

    var startDestination: String? by remember { mutableStateOf(null) }

    LaunchedEffect(Unit) {
        val loggedIn = loginStateManager.isLoggedIn()
        startDestination = if (!loggedIn) {
            AppRoute.IntroAuth.route
        } else {
            AppRoute.Dashboard.route
        }
    }

    val start = startDestination ?: return
    NavHost(
        navController = navController,
        startDestination = start
    ) {
        composable(AppRoute.IntroAuth.route) {
            IntroAuthScreen(
                onDone = {
                    navController.navigate(AppRoute.Dashboard.route) {
                        popUpTo(0)
                        launchSingleTop = true
                    }
                },
                callbackManager = callbackManager
            )
        }
        composable(AppRoute.Dashboard.route) {
            DashboardScreen(
                onOpenTxn = { id ->
                    navController.navigate(
                        AppRoute.TransactionDetail.createRoute(
                            id
                        )
                    )
                },
                onOpenBudgets = { navController.navigate(AppRoute.BudgetList.route) },
                onOpenChat = { navController.navigate(AppRoute.Chat.route) },
                onOpenSettings = { navController.navigate(AppRoute.Settings.route) }
            )
        }
        composable(AppRoute.Timeline.route) { TimelineScreen() }
        composable(
            route = AppRoute.TransactionDetail.route,
            arguments = listOf(navArgument("id") { type = NavType.StringType })
        ) { backStack ->
            val id = backStack.arguments?.getString("id")?.let(Uri::decode)!!
            TransactionDetailScreen(txnId = id)
        }
        composable(AppRoute.CreateTransaction.route) { CreateTransactionScreen() }
        composable(AppRoute.BudgetList.route) {
            BudgetListScreen(onOpenBudget = { id ->
                navController.navigate(AppRoute.BudgetDetail.createRoute(id))
            })
        }
        composable(
            route = AppRoute.BudgetDetail.route,
            arguments = listOf(navArgument("id") { type = NavType.StringType })
        ) { backStack ->
            val id = backStack.arguments?.getString("id")?.let(Uri::decode)!!
            BudgetDetailScreen(budgetId = id)
        }
        composable(AppRoute.Chat.route) { ChatScreen() }
        composable(AppRoute.Settings.route) {
            SettingsScreen(
                onLogout = {
                    loginStateManager.clear()
                    navController.navigateSingleTop(
                        AppRoute.Auth.route,
                        popTo = "main_graph",
                        inclusive = true
                    )
                },
                onUpsell = { navController.navigate(AppRoute.Upsell.route) }
            )
        }
        composable(AppRoute.Upsell.route) { UpsellScreen() }
    }
}
