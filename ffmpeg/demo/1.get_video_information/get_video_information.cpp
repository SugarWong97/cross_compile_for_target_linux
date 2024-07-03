#include <iostream>
using std::ios;
using std::cout;
using std::endl;

#ifdef __cplusplus
extern "C"{
#endif

// C code...
#include "libavcodec/avcodec.h"
#include "libavfilter/avfilter.h"
#include "libavformat/avformat.h"
#include "libavutil/avutil.h"
#include "libavutil/ffversion.h"
#include "libswresample/swresample.h"
#include "libswscale/swscale.h"
#include "libpostproc/postprocess.h"

#ifdef __cplusplus
}
#endif

int main(int argc, char * argv[])
{
    AVFormatContext* fmt_ctx = avformat_alloc_context();
    int ret = 0;
    const char* fileName = "resource/lenna-500X500.mp4"; //文件地址

    do {
        if ((ret = avformat_open_input(&fmt_ctx, fileName, NULL, NULL)) < 0)
            break;

        //查找流信息（音频流和视频流）
        if ((ret = avformat_find_stream_info(fmt_ctx, NULL)) < 0) {
            printf("Cannot find stream information\n");
            break;
        }

        av_dump_format(fmt_ctx, 0, fileName, 0);//输出视频信息
    } while (0);

    avformat_close_input(&fmt_ctx);//关闭文件
    return ret;
}
