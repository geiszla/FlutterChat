package com.mbaxaag2.flutterchat;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "flutterchat.mbaxaag2.com/audio";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL)
      .setMethodCallHandler(new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
          if (methodCall.method.equals("playAudio")) {
            int batteryLevel = 100;

            if (batteryLevel != -1) {
              result.success(batteryLevel);
            } else {
              result.error("UNAVAILABLE", "Battery level not available.", null);
            }
          } else {
            result.notImplemented();
          }
        }
      }
    );
  }
}
