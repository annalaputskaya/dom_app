package com.example.dom_app

import android.os.Bundle
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {

        MapKitFactory.setApiKey("d35da092-4e57-482b-b603-791e48e757a3")

        super.onCreate(savedInstanceState)
    }
}