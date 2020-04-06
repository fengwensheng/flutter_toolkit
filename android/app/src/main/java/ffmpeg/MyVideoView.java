package ffmpeg;

import android.content.Context;
import android.graphics.PixelFormat;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceView;

import ffmpeg.FFmpegNativeUtil;

public class MyVideoView extends SurfaceView {
    FFmpegNativeUtil util;
    Surface surface;
    public MyVideoView(Context context) {
        this(context,null);
    }
    public MyVideoView(Context context, AttributeSet attrs) {
        this(context, attrs,0);
    }
    public MyVideoView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }
    private void init(){
        getHolder().setFormat(PixelFormat.RGBA_8888);
        surface= getHolder().getSurface();
        util=new FFmpegNativeUtil();

    }
    /**
     * 开始播放
     * @param videoPath
     */
    public void startPlay(final String videoPath){
        new Thread(new Runnable() {
            @Override
            public void run() {
                Log.d("MyVideoView","------>>调用native方法");
                util.videoStreamPlay(videoPath,surface);
            }
        }).start();
    }
}