package com.mx.Tools;

/**
 * Created by xdj on 2017/3/7.
 */
import android.content.*;
import android.content.pm.*;
import android.graphics.Bitmap;
import android.graphics.drawable.*;

public class AppInfo
 {
    Context context;
    PackageManager pm;

    public AppInfo(Context context) {
        this.context = context;
        pm = context.getPackageManager();
    }

    /*
     * 获取程序 图标
     */
    public Drawable getAppIcon(String packname) {
        try {
            ApplicationInfo info = pm.getApplicationInfo(packname, 0);

            return info.loadIcon(pm);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();

        }
        return null;
    }

     public  synchronized Bitmap getBitmap(String packname) {
         ApplicationInfo applicationInfo = null;
         try {
             applicationInfo = pm.getApplicationInfo(
                     packname, 0);
         } catch (PackageManager.NameNotFoundException e) {
             e.printStackTrace();
         }

         assert applicationInfo != null;
         Drawable d = applicationInfo.loadIcon(pm); //xxx根据自己的情况获取drawable
         BitmapDrawable bd = (BitmapDrawable) d;
         Bitmap bm = bd.getBitmap();
         return bm;
     }
    /*
     *获取程序的版本号
     */
    public String getAppVersion(String packname) {

        try {
            PackageInfo packinfo = pm.getPackageInfo(packname, 0);
            return packinfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();

        }
        return null;
    }


    /*
     * 获取程序的名字
     */
    public String getAppName(String packname) {
        try {
            ApplicationInfo info = pm.getApplicationInfo(packname, 0);
            return info.loadLabel(pm).toString();
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();

        }
        return null;
    }

    /*
     * 获取程序的权限
     */
    public String[] getAppPremission(String packname) {
        try {
            PackageInfo packinfo = pm.getPackageInfo(packname, PackageManager.GET_PERMISSIONS);
            //获取到所有的权限
            return packinfo.requestedPermissions;

        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();

        }
        return null;
    }


    /*
     * 获取程序的签名
     */
    public String getAppSignature(String packname) {
        try {
            PackageInfo packinfo = pm.getPackageInfo(packname, PackageManager.GET_SIGNATURES);
            //获取到所有的权限
            return packinfo.signatures[0].toCharsString();

        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();

        }
        return null;
    }
}
