package com.africaonlinestores.app

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Enable edge-to-edge for Android 15+ (and backward compatible)
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // Optional: make status and navigation bars transparent
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        window.navigationBarColor = android.graphics.Color.TRANSPARENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // Optional: remove navigation bar divider color if needed
            window.navigationBarDividerColor = android.graphics.Color.TRANSPARENT
        }
    }
}
