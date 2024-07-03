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
    unsigned codecVer = avcodec_version();
    printf("FFmpeg version is: %s, avcodec version is: %d\n.", FFMPEG_VERSION, codecVer);



    int ver_major, ver_minor, ver_micro;
    ver_major = (codecVer >> 16) & 0xff;
    ver_minor = (codecVer >> 8) & 0xff;
    ver_micro = (codecVer) & 0xff;
    printf("Current ffmpeg version is: %s ,avcodec version is: %d=%d.%d.%d\n", FFMPEG_VERSION, codecVer, ver_major, ver_minor, ver_micro);

    return 0;
}
