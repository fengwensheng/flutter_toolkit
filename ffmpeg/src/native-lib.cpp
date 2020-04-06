#include <string>
#include <unistd.h>

#include "native-lib.h"
extern "C"
{
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include <libavutil/imgutils.h>
}
#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/shm.h>

#define MYPORT 8887
#define BUFFER_SIZE 1024
extern "C"
{
    void init_dart_print(callback func)
    {
        dart_print = func;
        //dart_print("初始化dart的print");
    }

    
    int Frame2JPG(AVFrame *pFrame, unsigned int stream_index,
                  int width, int height)
    {
        // 输出文件路径
        char out_file[80] = {0};
        sprintf(out_file, "/home/nightmare/文档/Flutter_Project/flutter_toolkit/build/linux/debug/data/Frame/%d.jpg", stream_index);

        // 分配AVFormatContext对象
        AVFormatContext *pFormatCtx = avformat_alloc_context();

        // 设置输出文件格式
        pFormatCtx->oformat = av_guess_format("mjpeg", NULL, NULL);

        // 创建并初始化一个和该url相关的AVIOContext
        if (avio_open(&pFormatCtx->pb, out_file, AVIO_FLAG_READ_WRITE) < 0)
        {
            printf("Couldn't open output file");
            return -1;
        }

        // 构建一个新stream
        AVStream *pAVStream = avformat_new_stream(pFormatCtx, 0);
        if (pAVStream == NULL)
        {
            printf("Frame2JPG::avformat_new_stream error.");
            return -1;
        }

        // 设置该stream的信息
        AVCodecContext *pCodecCtx = pAVStream->codec;

        pCodecCtx->codec_id = pFormatCtx->oformat->video_codec;
        pCodecCtx->color_range = AVCOL_RANGE_JPEG;
        pCodecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
        pCodecCtx->pix_fmt = AV_PIX_FMT_YUVJ420P;
        pCodecCtx->width = width;
        pCodecCtx->height = height;
        pCodecCtx->time_base.num = 1;
        pCodecCtx->time_base.den = 25;

        // 查找解码器
        AVCodec *pCodec = avcodec_find_encoder(pCodecCtx->codec_id);
        if (!pCodec)
        {
            printf("avcodec_find_encoder() error.");
            return -1;
        }
        // 设置pCodecCtx的解码器为pCodec
        if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0)
        {
            printf("Could not open codec.");
            return -1;
        }

        //Write Header
        int ret = avformat_write_header(pFormatCtx, NULL);
        if (ret < 0)
        {
            printf("avformat_write_header() error.\n");
            return -1;
        }

        int y_size = pCodecCtx->width * pCodecCtx->height;

        //Encode
        // 给AVPacket分配足够大的空间
        AVPacket pkt;
        av_new_packet(&pkt, y_size * 3);

        int got_picture = 0;
        ret = avcodec_encode_video2(pCodecCtx, &pkt, pFrame, &got_picture);
        if (ret < 0)
        {
            printf("avcodec_encode_video2() error.\n");
            return -1;
        }

        if (got_picture == 1)
        {
            ret = av_write_frame(pFormatCtx, &pkt);
        }
        FILE *fl;
        char complete[100] = {0};

        sprintf(complete, "/home/nightmare/文档/Flutter_Project/flutter_toolkit/build/linux/debug/data/Frame/%d", stream_index);
        fl = fopen(complete, "wb");
        fclose(fl);
        av_free_packet(&pkt);

        //Write Trailer
        av_write_trailer(pFormatCtx);

        if (pAVStream)
        {
            avcodec_close(pAVStream->codec);
        }

        avio_close(pFormatCtx->pb);
        avformat_free_context(pFormatCtx);

        return 0;
    }
   
    int videoStreamPlay(char *videoPath)
    {
        // int sock_cli = socket(AF_INET, SOCK_STREAM, 0);

        // ///定义sockaddr_in
        // struct sockaddr_in servaddr;
        // memset(&servaddr, 0, sizeof(servaddr));
        // servaddr.sin_family = AF_INET;
        // servaddr.sin_port = htons(MYPORT);                 ///服务器端口
        // servaddr.sin_addr.s_addr = inet_addr("127.0.0.1"); ///服务器ip

        // // dart_print("连接中");
        // //连接服务器，成功返回0，错误返回-1
        // if (connect(sock_cli, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0)
        // {
        //     perror("connect");

        //     //dart_print("连接失败");
        //     // exit(1);
        // }

        // dart_print("发送数据");
        // char sendbuf[BUFFER_SIZE];
        // char recvbuf[BUFFER_SIZE];
        // while (fgets(sendbuf, sizeof(sendbuf), stdin) != NULL)
        // {
        //     send(sock_cli, sendbuf, strlen(sendbuf), 0); ///发送
        //     if (strcmp(sendbuf, "exit\n") == 0)
        //         break;
        //     recv(sock_cli, recvbuf, sizeof(recvbuf), 0); ///接收
        //     fputs(recvbuf, stdout);

        //     memset(sendbuf, 0, sizeof(sendbuf));
        //     memset(recvbuf, 0, sizeof(recvbuf));
        // }

        // close(sock_cli);
        // return;

        // send(sock_cli, "dart调用视频播放", sizeof("dart调用视频播放"), 0); ///发送
        //dart_print("dart调用视频播放");
        const char *input = videoPath;
        if (input == NULL)
        {
            //LOGD("字符串转换失败......");
            return -1;
        }
        //注册FFmpeg所有编解码器，以及相关协议。
        av_register_all();
        //分配结构体
        AVFormatContext *formatContext = avformat_alloc_context();
        //打开视频数据源。由于Android 对SDK存储权限的原因，如果没有为当前项目赋予SDK存储权限，打开本地视频文件时会失败
        int open_state = avformat_open_input(&formatContext, input, NULL, NULL);
        if (open_state < 0)
        {
            char errbuf[128];
            if (av_strerror(open_state, errbuf, sizeof(errbuf)) == 0)
            {
                //LOGD("打开视频输入流信息失败，失败原因： %s", errbuf);
            }
            return -1;
        }
        //为分配的AVFormatContext 结构体中填充数据
        if (avformat_find_stream_info(formatContext, NULL) < 0)
        {
            //LOGD("读取输入的视频流信息失败。");
            return -1;
        }
        int video_stream_index = -1; //记录视频流所在数组下标
        //LOGD("当前视频数据，包含的数据流数量：%d", formatContext->nb_streams);
        //找到"视频流".AVFormatContext 结构体中的nb_streams字段存储的就是当前视频文件中所包含的总数据流数量——
        //视频流，音频流，字幕流
        for (int i = 0; i < formatContext->nb_streams; i++)
        {

            //如果是数据流的编码格式为AVMEDIA_TYPE_VIDEO——视频流。
            if (formatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO)
            {
                video_stream_index = i; //记录视频流下标
                break;
            }
        }
        if (video_stream_index == -1)
        {
            //LOGD("没有找到 视频流。");
            return -1;
        }
        //通过编解码器的id——codec_id 获取对应（视频）流解码器
        AVCodecParameters *codecParameters = formatContext->streams[video_stream_index]->codecpar;
        AVCodec *videoDecoder = avcodec_find_decoder(codecParameters->codec_id);

        if (videoDecoder == NULL)
        {
            //LOGD("未找到对应的流解码器。");
            return -1;
        }
        //通过解码器分配(并用  默认值   初始化)一个解码器context
        AVCodecContext *codecContext = avcodec_alloc_context3(videoDecoder);

        if (codecContext == NULL)
        {
            //LOGD("分配 解码器上下文失败。");
            return -1;
        }
        //更具指定的编码器值填充编码器上下文
        if (avcodec_parameters_to_context(codecContext, codecParameters) < 0)
        {
            //LOGD("填充编解码器上下文失败。");
            return -1;
        }
        //通过所给的编解码器初始化编解码器上下文
        if (avcodec_open2(codecContext, videoDecoder, NULL) < 0)
        {
            //LOGD("初始化 解码器上下文失败。");
            return -1;
        }
        AVPixelFormat dstFormat = AV_PIX_FMT_YUVJ420P;
        //分配存储压缩数据的结构体对象AVPacket
        //如果是视频流，AVPacket会包含一帧的压缩数据。
        //但如果是音频则可能会包含多帧的压缩数据
        AVPacket *packet = av_packet_alloc();
        //分配解码后的每一数据信息的结构体（指针）
        AVFrame *frame = av_frame_alloc();
        //分配最终显示出来的目标帧信息的结构体（指针）
        AVFrame *outFrame = av_frame_alloc();
        uint8_t *out_buffer = (uint8_t *)av_malloc(
            (size_t)av_image_get_buffer_size(dstFormat, codecContext->width, codecContext->height,
                                             1));
        //更具指定的数据初始化/填充缓冲区
        av_image_fill_arrays(outFrame->data, outFrame->linesize, out_buffer, dstFormat,
                             codecContext->width, codecContext->height, 1);
        //初始化SwsContext
        codecContext->pix_fmt = AV_PIX_FMT_YUVJ420P;
        codecContext->color_range = AVCOL_RANGE_JPEG;
        SwsContext *swsContext = sws_getContext(
            codecContext->width //原图片的宽
            ,
            codecContext->height //源图高
            ,
            codecContext->pix_fmt //源图片format
            ,
            codecContext->width //目标图的宽
            ,
            codecContext->height //目标图的高
            ,
            dstFormat, SWS_BICUBIC, NULL, NULL, NULL);
        if (swsContext == NULL)
        {
            //LOGD("swsContext==NULL");
            return -1;
        }
        //循环读取数据流的下一帧
        int index = 0;
        while (av_read_frame(formatContext, packet) == 0)
        {

            if (packet->stream_index == video_stream_index)
            {
                //讲原始数据发送到解码器
                int sendPacketState = avcodec_send_packet(codecContext, packet);
                if (sendPacketState == 0)
                {
                    int receiveFrameState = avcodec_receive_frame(codecContext, frame);
                    if (receiveFrameState == 0)
                    {
                        //锁定窗口绘图界面
                        //对输出图像进行色彩，分辨率缩放，滤波处理
                        sws_scale(swsContext, (const uint8_t *const *)frame->data, frame->linesize, 0,
                                  frame->height, outFrame->data, outFrame->linesize);
                        Frame2JPG(outFrame, index++, codecContext->width, codecContext->height);
                        // MyWriteJPEG(outFrame, codecContext->width, codecContext->height, index++);
                        // SaveFrame(outFrame, codecContext->width, codecContext->height, index++); //保存图片
                        // if (index > 50)
                        // return 0; //这里我们就保存50张图片
                        // FILE *fp = NULL;
                        // fp = fopen("/sdcard/MToolkit/tmp.jpg", "w+");
                        // for (int y = 0; y < codecContext->height; y++)
                        // {
                        //     fwrite(outFrame->data[0] + y * outFrame->linesize[0], 1, codecContext->width * 3, fp);
                        // }
                        // fclose(fp);
                        // uint8_t *dst = (uint8_t *) outBuffer.bits;
                        //解码后的像素数据首地址
                        //这里由于使用的是RGBA格式，所以解码图像数据只保存在data[0]中。但如果是YUV就会有data[0]
                        //data[1],data[2]
                        // uint8_t *src = outFrame->data[0];
                        //获取一行字节数
                        // int oneLineByte = outBuffer.stride * 4;
                        //复制一行内存的实际数量
                        // int srcStride = outFrame->linesize[0];
                        // for (int i = 0; i < codecContext->height; i++) {
                        //     memcpy(dst + i * oneLineByte, src + i * srcStride, srcStride);
                        // }
                        //解锁
                        // ANativeWindow_unlockAndPost(nativeWindow);
                        //进行短暂休眠。如果休眠时间太长会导致播放的每帧画面有延迟感，如果短会有加速播放的感觉。
                        //一般一每秒60帧——16毫秒一帧的时间进行休眠
                        usleep(1000 * 10); //20毫秒
                    }
                    else if (receiveFrameState == AVERROR(EAGAIN))
                    {
                        //LOGD("从解码器-接收-数据失败：AVERROR(EAGAIN)");
                    }
                    else if (receiveFrameState == AVERROR_EOF)
                    {
                        //LOGD("从解码器-接收-数据失败：AVERROR_EOF");
                    }
                    else if (receiveFrameState == AVERROR(EINVAL))
                    {
                        //LOGD("从解码器-接收-数据失败：AVERROR(EINVAL)");
                    }
                    else
                    {
                        //LOGD("从解码器-接收-数据失败：未知");
                    }
                }
                else if (sendPacketState == AVERROR(EAGAIN))
                { //发送数据被拒绝，必须尝试先读取数据
                    //LOGD("向解码器-发送-数据包失败：AVERROR(EAGAIN)");//解码器已经刷新数据但是没有新的数据包能发送给解码器
                }
                else if (sendPacketState == AVERROR_EOF)
                {
                    //LOGD("向解码器-发送-数据失败：AVERROR_EOF");
                }
                else if (sendPacketState == AVERROR(EINVAL))
                { //遍解码器没有打开，或者当前是编码器，也或者需要刷新数据
                    //LOGD("向解码器-发送-数据失败：AVERROR(EINVAL)");
                }
                else if (sendPacketState == AVERROR(ENOMEM))
                { //数据包无法压如解码器队列，也可能是解码器解码错误
                    //LOGD("向解码器-发送-数据失败：AVERROR(ENOMEM)");
                }
                else
                {
                    //LOGD("向解码器-发送-数据失败：未知");
                }
            }
            av_packet_unref(packet);
        }
        //内存释放
        // ANativeWindow_release(nativeWindow);
        av_frame_free(&outFrame);
        av_frame_free(&frame);
        av_packet_free(&packet);
        avcodec_free_context(&codecContext);
        avformat_close_input(&formatContext);
        avformat_free_context(formatContext);
        // env->ReleaseStringUTFChars(videoPath, input);
    }

    // void SaveFrame(AVFrame *pFrame, int width, int height, int index)
    // {

    //     FILE *pFile;
    //     char szFilename[60];
    //     int y;

    //     // Open file
    //     sprintf(szFilename, "/sdcard/MToolkit/Frame/frame%d.ppm", index); //文件名
    //     pFile = fopen(szFilename, "wb");

    //     if (pFile == nullptr)
    //         return;

    //     // Write header
    //     fprintf(pFile, "P6 %d %d 255", width, height);

    //     // Write pixel data
    //     for (y = 0; y < height; y++)
    //     {
    //         fwrite(pFrame->data[0] + y * pFrame->linesize[0], 1, width * 3, pFile);
    //     }

    //     // Close file
    //     fclose(pFile);
    // }
}
