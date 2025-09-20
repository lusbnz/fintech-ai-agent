package com.ltcn272.finny.core.navigation

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import com.ltcn272.finny.core.LoginStateManager

@HiltViewModel
class ManagerProviderViewModel @Inject constructor(
    val loginStateManager: LoginStateManager
) : ViewModel()

