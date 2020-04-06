#include "SocketConnection.h"

extern "C"
{
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include <libavutil/imgutils.h>
}
typedef void(*callback)(char *p);
void init_dart_print(callback dartprint);

class FFmpegDecoder {
public:
    SocketConnection *connection;

    AVFormatContext *format_ctx;
    AVCodecContext *codec_ctx;
    AVIOContext *avio_ctx;

    AVPacket *packet;

    bool request_stop;

    FFmpegDecoder(SocketConnection *connection);


    bool init();

    bool async_start();

    void _decode_loop();

    void stop();

    void destroy();
};

