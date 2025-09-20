package com.ltcn272.finny

import android.app.Application
import com.facebook.appevents.AppEventsLogger
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class App : Application() {
    override fun onCreate() {
        super.onCreate()
        AppEventsLogger.activateApp(this)
    }
}