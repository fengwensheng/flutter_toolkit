package com.nightmare;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.PixelFormat;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Looper;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceView;
import android.widget.Toast;

import com.mx.Tools.AppInfo;
import com.Nightmare.Tools.WriteTxt;


import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import brut.common.BrutException;
import ffmpeg.FFmpegNativeUtil;
import ffmpeg.MyVideoView;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.TextureRegistry;

import static android.content.pm.PackageManager.PERMISSION_GRANTED;


public class MainActivity extends FlutterActivity {
    public static String getEmojiStringByUnicode(int unicode) {//将一个Unicode码转换为一个表情图
        return new String(Character.toChars(unicode));
    }

    private static final String DrawerHeader = "DrawerHeader";
    private static final String Toast0 = "Toast";
    private static final String Fifth = "Fifth";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        initPlugin();
    }

    void initPlugin() {
        new Thread(() -> {
            DrawerHeader();//侧拉栏
            Toast0();
            Fifth();
            initPermissionPlugin();
            SomeThing();
            initDecompilePlugin();
            initSendBroadcastPlugin();
            App();
            GetApp();
        }).start();
    }

    @SuppressLint("SdCardPath")
    private void initDecompilePlugin() {
        new MethodChannel(getFlutterView(), "Decompile").setMethodCallHandler((call, result) -> new Thread(() -> {
            String id = call.method;
            String[] args = {};
            if (!id.equals("logout"))
                args = (String[]) ((ArrayList) call.arguments).toArray(new String[0]);
            switch (id) {
                case "logout":
                    //重定向java的标准输入输出
                    try {
                        System.setErr(new PrintStream(new FileOutputStream(new File(call.arguments.toString()), true), true));
                        System.setOut(new PrintStream(new FileOutputStream(new File(call.arguments.toString()), true), true));
                    } catch (FileNotFoundException e) {
                        e.printStackTrace();
                    }

                    runOnUiThread(() -> result.success(""));
                    break;

                case "apktool"://apktool的
                    try {
                        brut.apktool.Main.main(args);
                    } catch (IOException e) {
                        //methodChannel.invokeMethod("Terminal", e.getMessage());
                        e.printStackTrace();
                    } catch (InterruptedException e) {
                        //methodChannel.invokeMethod("Terminal", e.getMessage());
                        e.printStackTrace();
                    } catch (BrutException e) {
                        //methodChannel.invokeMethod("Terminal", e.getMessage());
                        e.printStackTrace();
                    }

                    runOnUiThread(() -> result.success(""));
                    break;
                case "smali":
                    org.jf.smali.Main.main(args);

                    runOnUiThread(() -> result.success(""));
                    break;
                case "baksmali":
                    org.jf.baksmali.Main.main(args);
                    runOnUiThread(() -> result.success(""));
                    //String[] A = new String[]{"d", "/storage/emulated/0/Apktool/jar/1/classes.dex", "-o", "/storage/emulated/0/Apktool/jar/1/sdasd"};
//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            Dynamic dynamic;
//                            File cacheFile = FileUtils.getCacheDir(getApplicationContext());
//                            //String[] A = new String[]{"d", "/storage/emulated/0/Apktool/jar/1/classes.dex", "-o", "/storage/emulated/0/Apktool/jar/1/sdasd"};
//                            //下面开始加载dex class
//                            @SuppressLint("SdCardPath") DexClassLoader dexClassLoader = new DexClassLoader("/sdcard/Apktool/apktool.dex", cacheFile.getAbsolutePath(), null, getClassLoader());
//                            try {
//                                Class libClazz = dexClassLoader.loadClass("com.nightmare.Decomplie");
//                                dynamic = (Dynamic) libClazz.newInstance();
//                                String[] args= (String[]) ((ArrayList)call.arguments).toArray(new String[0]);
//                                if (dynamic != null)
//                                    dynamic.main(args);
//                            } catch (Exception e) {
//                                e.printStackTrace();
//                            }
//                        }
//                    });
                    //Main.main(A);
                    break;
            }
        }).start());
    }


    void GetApp() {
        new MethodChannel(getFlutterView(), "GetAppIcon").setMethodCallHandler((call, result) -> {
            AppInfo info = new AppInfo(getApplicationContext());

            Bitmap bitmap = info.getBitmap(call.method);
            saveBitmap(bitmap, call.method);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    result.success("");
                }
            });
            //new RunCommandTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, call.method);
        });
    }

    public void saveBitmap(Bitmap bm, String picName) {
        File f = new File(this.getFilesDir().getPath() + "/AppManager/.icon", picName);
        if (f.exists()) {
            f.delete();
        }
        try {
            FileOutputStream out = new FileOutputStream(f);
            bm.compress(Bitmap.CompressFormat.PNG, 10, out);
            out.flush();
            out.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }


    void App() {
        new MethodChannel(getFlutterView(), "App").setMethodCallHandler((call, result) -> new Thread(() -> {
            List<String> id = stringToList(call.method);
            StringBuilder list = new StringBuilder();
            for (String a : id) {
                try {
                    PackageInfo packages = getPackageManager().getPackageInfo(a, 0);
                    list.append(packages.applicationInfo.loadLabel(getPackageManager())).append("\n");
                } catch (PackageManager.NameNotFoundException e) {
                    e.printStackTrace();
                }
            }
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    result.success(list.toString());
                }
            });

        }).start());
        new MethodChannel(getFlutterView(), "GetAppInfo").setMethodCallHandler((call, result) -> new Thread(() -> {

            try {
                PackageInfo packages = getPackageManager().getPackageInfo(call.method, 0);
                ActivityInfo[] actInfo = getPackageManager().getPackageInfo(packages.packageName, PackageManager.GET_ACTIVITIES).activities;
                StringBuilder list = new StringBuilder();
//                if(actInfo!=null)
//                for (ActivityInfo a : actInfo) {
//                    list.append(a.name).append("\n");
//                }
                Intent mainIntent = new Intent(Intent.ACTION_MAIN, null);
                mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
                List<ResolveInfo> appList=getPackageManager().queryIntentActivities(mainIntent, 0);
                for (int i = 0; i < appList.size(); i++) {
                    ResolveInfo resolveInfo = appList.get(i);
                    String packageStr = resolveInfo.activityInfo.packageName;
                    if (packageStr.equals(call.method)) {
                        //这个就是你想要的那个Activity
                        list.append(resolveInfo.activityInfo.name).append("\n");
                        break;
                    }
                }
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        result.success(list.toString());
                    }
                });
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }


        }).start());
    }

    static {
        System.loadLibrary("native-lib");
    }


    private void initSendBroadcastPlugin() {//发送一个广播
        new MethodChannel(getFlutterView(), "SendBroadcast").setMethodCallHandler((call, result) -> {
            Intent intent = new Intent(call.method);
            intent.putExtra("msg", call.arguments.toString());
            this.sendBroadcast(intent);
            runOnUiThread(() -> result.success(""));
        });
    }


    private void SomeThing() {
        new MethodChannel(getFlutterView(), "SomeThing").setMethodCallHandler((call, result) -> {
            Intent intent1 = new Intent();
            intent1.setAction(Intent.ACTION_VIEW);
            intent1.setData(Uri.parse(call.method));
            intent1.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent1);
        });
        new MethodChannel(getFlutterView(), "VideoCall").setMethodCallHandler((call, result) -> {
            FFmpegNativeUtil util = new FFmpegNativeUtil();
            TextureRegistry textures = this.registrarFor("nightmare/video").textures();
            TextureRegistry.SurfaceTextureEntry textureEntry = textures.createSurfaceTexture();
            Surface surface = new Surface(textureEntry.surfaceTexture());
            new Thread(new Runnable() {
                @Override
                public void run() {
                    Log.d("MyVideoView", "------>>调用native方法");
                    util.videoStreamPlay("/storage/emulated/0/1.mp4", surface);
                }
            }).start();
            result.success(textureEntry.id());
        });

    }

    @SuppressLint("SdCardPath")
    private void initPermissionPlugin() {
        new MethodChannel(getFlutterView(), "permission").setMethodCallHandler((call, result) -> new Thread(() -> {
            String id = call.method;
            switch (id) {
                case "Permission_Check":
                    if (Build.VERSION.SDK_INT >= 23) {//判断当前系统的版本如果没有被授予
                        int checkWriteStoragePermission = this.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE);//获取系统是否被授予该种权限
                        if (checkWriteStoragePermission != PERMISSION_GRANTED) {//如果没有被授予
                            //请求获取该种权限
                            runOnUiThread(() -> result.success(false));
                        } else runOnUiThread(() -> result.success(true));
                    } else runOnUiThread(() -> result.success(true));
                    break;
                case "EXTERNAL_STORAGE":
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        this.requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
                    }
                    //请求获取该种权限
                    break;
            }
        }).start());
    }


    void Fifth() {
        new MethodChannel(getFlutterView(), Fifth).setMethodCallHandler((call, result) -> {
            String id = call.method;
            switch (id) {
                case "KaiFa":
                    new Thread(() -> {
                        try {
                            MainActivity.this.startActivity(new Intent("com.android.settings.APPLICATION_DEVELOPMENT_SETTINGS"));
                        } catch (Throwable e) {
                            Looper.prepare();
                            Toast.makeText(MyApplication.getAppContext(), "打开方式失效了" + getEmojiStringByUnicode(128527), Toast.LENGTH_SHORT).show();
                            Looper.loop();
                            e.printStackTrace();
                        }

                    }).start();
                    break;
                case "Test":
                    new Thread(() -> {
                        try {
                            MainActivity.this.startActivity(new Intent().setClassName("com.android.settings", "com.android.settings.Settings$TestingSettingsActivity"));
                        } catch (Throwable e) {
                            Looper.prepare();
                            Toast.makeText(MyApplication.getAppContext(), "打开方式失效了" + getEmojiStringByUnicode(128527), Toast.LENGTH_SHORT).show();
                            Looper.loop();
                            e.printStackTrace();
                        }
                    }).start();
                    break;
            }
        });
    }

    private List<String> stringToList(String strs) {
        String[] str = strs.split("\n");
        return Arrays.asList(str);
    }

    void Toast0() {
        new MethodChannel(getFlutterView(), Toast0).setMethodCallHandler((call, result) -> {
            new Thread(() -> {
                try {
                    int a;
                    int b;
                    if (call.argument("Emoji") == null) {
                        a = 0x1F601;
                    } else {
                        a = call.argument("Emoji");
                    }
                    if (call.argument("time") == null) {
                        b = Toast.LENGTH_SHORT;
                    } else {
                        b = Toast.LENGTH_LONG;
                    }
                    Looper.prepare();
                    Toast.makeText(MyApplication.getAppContext(), call.method + getEmojiStringByUnicode(a), b).show();
                    runOnUiThread(() -> result.success(""));
                    Looper.loop();
                } catch (Throwable throwable) {
                    throwable.printStackTrace();
                }
            }).start();
            //Toast.makeText(MainActivity.this,"正在执行相关脚本，请等待两秒左右" + com.Nightmare.MainActivity.getEmojiStringByUnicode(128527), Toast.LENGTH_SHORT).show();
        });
    }

    void DrawerHeader() {
        new MethodChannel(getFlutterView(), DrawerHeader).setMethodCallHandler(new MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
                String id = call.method;
                switch (id) {
                    case "Exit":
                        finish();
                        break;
                    case "Share":
                        Intent shareIntent = new Intent(Intent.ACTION_SEND);
                        System.out.println(call.arguments.toString());
                        shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(new File(call.arguments.toString())));
                        shareIntent.setType("application/vnd.android.package-archive");
                        startActivity(Intent.createChooser(shareIntent, "分享M工具箱到："));
                        break;
                }

            }
        });

    }

//    @Override
//    public void onRequestPermissionsResult(int requestCode, String[] permissions,
//                                           int[] grantResults) {
//        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
//        if (requestCode == 1) {
//            for (int i = 0; i < permissions.length; i++) {
//                if (grantResults[i] == PERMISSION_GRANTED) {
//                    //Toast.makeText(MyApplication.getAppContext(), "" + "权限" + permissions[i] + "申请成功", Toast.LENGTH_SHORT).show();
//                } else {
//                    //Toast.makeText(MyApplication.getAppContext(), "" + "权限" + permissions[i] + "申请失败", Toast.LENGTH_SHORT).show();
//                }
//            }
//        }
//    }

}
