package com.readylocal.partner

import android.app.ActivityManager
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Job alert setup: reads the phone settings that decide whether job alerts can
 * reach a closed app, and opens the right settings page for each one.
 * Nothing here changes a setting by itself; the partner does it on the phone.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.readylocal.partner/alert_setup"
    private val jobChannelId = "job_requests"

    /** Phone makers' "Autostart" pages, tried in order. */
    private val autostartPages = listOf(
        // Xiaomi, Redmi, POCO
        ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
        // Oppo, Realme (ColorOS / Realme UI)
        ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
        ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"),
        ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
        ComponentName("com.coloros.oppoguardelf", "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity"),
        // Vivo, iQOO
        ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
        ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager"),
        ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
        // Huawei, Honor
        ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
        ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
        ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
        // OnePlus
        ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"),
        // Asus
        ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.entry.FunctionActivity"),
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "status" -> result.success(status())
                    "open" -> result.success(open(call.argument<String>("page") ?: "app"))
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("alert_setup", e.message, null)
            }
        }
    }

    private fun status(): Map<String, Any?> {
        val notifications = NotificationManagerCompat.from(this).areNotificationsEnabled()
        var jobChannel = true
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channel = nm.getNotificationChannel(jobChannelId)
            if (channel != null) jobChannel = channel.importance >= NotificationManager.IMPORTANCE_HIGH
        }
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val batteryFree = pm.isIgnoringBatteryOptimizations(packageName)
        var restricted = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            restricted = am.isBackgroundRestricted
        }
        return mapOf(
            "notifications" to notifications,
            "jobChannel" to jobChannel,
            "batteryUnrestricted" to batteryFree,
            "backgroundRestricted" to restricted,
            "hasAutostart" to (autostartIntent() != null),
            "isXiaomi" to isXiaomi(),
            "manufacturer" to Build.MANUFACTURER,
            "sdk" to Build.VERSION.SDK_INT,
        )
    }

    private fun isXiaomi(): Boolean {
        val m = Build.MANUFACTURER.lowercase()
        return m.contains("xiaomi") || m.contains("redmi") || m.contains("poco")
    }

    private fun autostartIntent(): Intent? {
        for (c in autostartPages) {
            val intent = Intent().setComponent(c).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (resolves(intent)) return intent
        }
        return null
    }

    private fun resolves(intent: Intent): Boolean =
        intent.resolveActivity(packageManager) != null ||
            packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY).isNotEmpty()

    private fun appDetails(): Intent =
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    /** Opens the page; falls back to the app's own settings page. */
    private fun open(page: String): Boolean {
        val candidates = mutableListOf<Intent>()
        when (page) {
            "notifications" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                candidates += Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
            "jobChannel" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                candidates += Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    .putExtra(Settings.EXTRA_CHANNEL_ID, jobChannelId)
            }
            // App info > Battery > "Unrestricted" / "Don't optimise". The direct
            // request dialog needs a permission Google Play restricts, so it is not used.
            "battery" -> candidates += appDetails()
            "autostart" -> autostartIntent()?.let { candidates += it }
            "popup" -> if (isXiaomi()) {
                candidates += Intent("miui.intent.action.APP_PERM_EDITOR")
                    .setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                    .putExtra("extra_pkgname", packageName)
                candidates += Intent("miui.intent.action.APP_PERM_EDITOR")
                    .setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity")
                    .putExtra("extra_pkgname", packageName)
            }
        }
        candidates += appDetails()
        for (intent in candidates) {
            try {
                startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                return true
            } catch (_: Exception) {
                // Not on this phone; try the next page.
            }
        }
        return false
    }
}
