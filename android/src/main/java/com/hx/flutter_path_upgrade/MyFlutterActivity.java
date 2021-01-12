package com.hx.flutter_path_upgrade;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import java.io.File;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterShellArgs;

public class MyFlutterActivity extends FlutterActivity {
    @Override
    public FlutterShellArgs getFlutterShellArgs() {
        Log.e("启动x","==============");
        SharedPreferences sp = getSharedPreferences("up", Context.MODE_PRIVATE);
        String upgrade_file = sp.getString("useso", "x.so");

        FlutterShellArgs supFA = super.getFlutterShellArgs();

        File libFile = new File(upgrade_file);
        Log.e("启动x","=======aaa=======" + libFile.getAbsolutePath());
        if (libFile.exists()) {
            Log.e("启动x","=======cccc=======" + libFile.getAbsolutePath());
            supFA.add("--aot-shared-library-name=" + libFile.getAbsolutePath());   //如果有hotlibapp文件 ,配置进去,没有则作用默认的
        }
        return supFA;
    }
}