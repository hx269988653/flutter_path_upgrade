package com.hx.flutter_path_upgrade;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Process;
import android.content.pm.PackageManager;
import android.text.TextUtils;
import android.util.Log;

import com.cundong.utils.PatchUtils;
import java.io.File;
import androidx.annotation.NonNull;

import java.util.Map;

import dalvik.system.PathClassLoader;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterPathUpgradePlugin */
public class FlutterPathUpgradePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context appContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    appContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_path_upgrade");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("restart")) {
      restartApplication();
    } else if (call.method.equals("merge")) {
      Map<String, String> map = call.arguments();
      Log.e("merge",map.get("oldfile"));
      if (new File(map.get("oldfile")).exists() && new File(map.get("patch")).exists()) {
        int state = PatchUtils.patch(map.get("oldfile"), map.get("newfile"), map.get("patch"));
        if(state == 0){
          result.success(1);
        }else{
          result.success(0);
        }
      } else {
        result.success(0);
      }
    }else if (call.method.equals("findNativeLibraryPath")) {
      result.success(findNativeLibraryPath(call.arguments().toString()));
    } else if (call.method.equals("getDataDir")) {
      result.success(appContext.getDir(call.arguments().toString(), appContext.MODE_PRIVATE).getAbsolutePath());
    } else if (call.method.equals("setUpgradeFile")) {
      SharedPreferences sp = appContext.getSharedPreferences("up", Context.MODE_PRIVATE);
      sp.edit().putString("useso", call.arguments().toString()).commit();

      Log.e("xxxxxxxx", "====saveUpgradeFile==111=====" + call.arguments.toString());
      Log.e("xxxxxxxx", "====saveUpgradeFile==111=====" + sp.getString("useso", "mmm.so"));
      result.success(1);
    } else if (call.method.equals("getUpgradeFile")) {
      SharedPreferences sp = appContext.getSharedPreferences("up", Context.MODE_PRIVATE);
      result.success(sp.getString("useso", ""));
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  void restartApplication(){
    Intent intent = appContext.getPackageManager().getLaunchIntentForPackage(appContext.getPackageName());
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
            | Intent.FLAG_ACTIVITY_CLEAR_TOP
            | Intent.FLAG_ACTIVITY_CLEAR_TASK);
    appContext.startActivity(intent);
//    appContext.overridePendingTransition(0, 0);
    Process.killProcess(Process.myPid());
    System.exit(0);
  }

  String findNativeLibraryPath(String libraryName) {
    if (appContext == null || TextUtils.isEmpty(libraryName)) {
      return null;
    }
    PathClassLoader classLoader = (PathClassLoader)appContext.getClassLoader();
    return classLoader.findLibrary(libraryName);
  }
}
