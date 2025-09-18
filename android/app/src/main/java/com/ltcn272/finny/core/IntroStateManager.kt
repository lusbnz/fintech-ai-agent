package com.ltcn272.finny.core

import android.content.SharedPreferences
import androidx.core.content.edit
import javax.inject.Inject

class IntroStateManager @Inject constructor(private val sp: SharedPreferences) {
    private val K_SEEN_INTRO = "seen_intro"
    fun hasSeenIntro() = sp.getBoolean(K_SEEN_INTRO, false)
    fun setSeenIntro(v: Boolean) = sp.edit { putBoolean(K_SEEN_INTRO, v) }
}