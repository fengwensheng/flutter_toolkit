package ffmpeg;

import android.graphics.SurfaceTexture;
import android.view.Surface;

public class FFmpegNativeUtil {
    static {
//        System.loadLibrary("avcodec");
//        System.loadLibrary("avdevice");
//        System.loadLibrary("avfilter");
//        System.loadLibrary("avformat");
//        System.loadLibrary("avutil");
//        System.loadLibrary("postproc");
//        System.loadLibrary("swresample");
//        System.loadLibrary("swscale");
//        System.loadLibrary("native-lib");
    }
    /**
     * 播放视频流
     * @param videoPath（本地）视频文件路径
     * @param surface
     */
    public native void videoStreamPlay(String videoPath, Surface surface);
}