package rem.reminds.you

import android.app.Service
import android.content.Intent
import android.os.IBinder
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class AlarmService : Service() {
    private val ENGINE_ID = "my_app_engine"
    private val CHANNEL = "app_permission_channel"

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (flutterEngine != null) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("openAlarmScreen", null)
        } else {
            // Handle the case where the engine is not found
            println("FlutterEngine not found in cache")
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder? = null
}