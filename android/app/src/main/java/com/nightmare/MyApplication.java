package com.nightmare;
import android.content.Context;
import android.graphics.Typeface;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
    public static Typeface TypeFaceYaHei;
    private static Context context;

	private static MyApplication mApplication;

	public synchronized static MyApplication getInstance() {
		return mApplication;
}

	private void initData() {
		//当程序发生Uncaught异常的时候,由该类来接管程序,一定要在这里初始化
	}
	
	
		
    public void onCreate() {
        super.onCreate();
        context = getApplicationContext();
		initData();
    }

    public static Context getAppContext() {
        return context;
    }
}
