#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define DEBUG

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <xf86drm.h>
#include <xf86drmMode.h>

struct buffer_object {
    uint32_t pitch;     //像素间距
    uint32_t handle;
    uint32_t size;
    uint8_t *vaddr;
    uint32_t fb_id;
};


void debugDrmModeRes(drmModeResPtr res) {
    if(!res) return;
    /*typedef struct _drmModeRes {

    int count_fbs;
    uint32_t *fbs;

    int count_crtcs;
    uint32_t *crtcs;

    int count_connectors;
    uint32_t *connectors;

    int count_encoders;
    uint32_t *encoders;

    uint32_t min_width, max_width;
    uint32_t min_height, max_height;
} drmModeRes, *drmModeResPtr;*/

    printf("drmModeResources: \n");
    printf("fbs:\t");
    for(int i = 0;i < res->count_fbs;i++) {
        printf("%d ", res->fbs[i]);
    }
    printf("\n");

    printf("crtcs:\t");
    for(int i = 0;i < res->count_crtcs;i++) {
        printf("%d ", res->crtcs[i]);
    }
    printf("\n");

    printf("connectors:\t");
    for(int i = 0;i < res->count_connectors;i++) {
        printf("%d ", res->connectors[i]);
    }
    printf("\n");

    printf("encoders:\t");
    for(int i = 0;i < res->count_encoders;i++) {
        printf("%d ", res->encoders[i]);
    }
    printf("\n");

    printf("width range:\t%d~%d\n", res->min_width, res->max_width);
    printf("height range:\t%d~%d\n", res->min_height, res->max_height);
}

void debugConnector(drmModeConnectorPtr connector) {
#if 0
typedef struct _drmModeConnector {
    uint32_t connector_id;
    uint32_t encoder_id; /**< Encoder currently connected to */
    uint32_t connector_type;
    uint32_t connector_type_id;
    /*
    连接状态
    typedef enum {
        DRM_MODE_CONNECTED         = 1,
        DRM_MODE_DISCONNECTED      = 2,
        DRM_MODE_UNKNOWNCONNECTION = 3
    } drmModeConnection;
    */
    drmModeConnection connection;
    uint32_t mmWidth, mmHeight; /**< HxW in millimeters */
    drmModeSubPixel subpixel;

    int count_modes;
    drmModeModeInfoPtr modes;

    int count_props;
    uint32_t *props; /**< List of property ids */
    uint64_t *prop_values; /**< List of property values */

    int count_encoders;
    uint32_t *encoders; /**< List of encoder ids */
} drmModeConnector, *drmModeConnectorPtr;
#endif
    printf("connector modes: \n");
    for(int i = 0;i< connector->count_modes;i++) {
        printf("mode %s:\n", connector->modes[i].name);
    }
}

static void modeset_create_fb(int fd, struct buffer_object *bo){
#if 0
    /* create a dumb scanout buffer */
struct drm_mode_create_dumb {
    __u32 height;
    __u32 width;
    __u32 bpp;
    __u32 flags;
    /* handle, pitch, size will be returned */
    __u32 handle;
    __u32 pitch;
    __u64 size;
};

/* set up for mmap of a dumb scanout buffer */
struct drm_mode_map_dumb {
    /** Handle for the object being mapped. */
    __u32 handle;
    __u32 pad;
    /**
     * Fake offset to use for subsequent mmap call
     *
     * This is a fixed-size type for 32/64 compatibility.
     */
    __u64 offset;
};
#endif
    //创建dumb-buffer
    struct drm_mode_create_dumb create = {};
    struct drm_mode_map_dumb map = {};

    create.width = 1920;
    create.height = 1080;
    create.bpp = 32;
    drmIoctl(fd, DRM_IOCTL_MODE_CREATE_DUMB, &create);
    bo->pitch = create.pitch;
    bo->size = create.size;
    bo->handle = create.handle;

    //绑定dumb-buffer到FB，这一步返回fb_id
#if 0
    /**
 * Creates a new framebuffer with an buffer object as its scanout buffer.
 */
extern int drmModeAddFB(int fd, uint32_t width, uint32_t height, uint8_t depth,
            uint8_t bpp, uint32_t pitch, uint32_t bo_handle,
            uint32_t *buf_id);
#endif
    drmModeAddFB(fd, create.width, create.height, 24, 32, bo->pitch, bo->handle, &bo->fb_id);

    //映射dumb-buffer到用户空间
    map.handle = create.handle;
    drmIoctl(fd, DRM_IOCTL_MODE_MAP_DUMB, &map);
    bo->vaddr = (uint8_t*)mmap(NULL, create.size, PROT_READ|PROT_WRITE,
        MAP_SHARED, fd, map.offset);
}

void modeset_destory_fb(int fd, struct buffer_object *bo) {
//  struct drm_mode_destroy_dumb {
//  __u32 handle;
// };
    struct drm_mode_destroy_dumb destroy = {};
    drmModeRmFB(fd, bo->fb_id);
    destroy.handle = bo->handle;
    drmIoctl(fd, DRM_IOCTL_MODE_DESTROY_DUMB, &destroy);
}


int main(void){
    drmModeResPtr res = NULL;
    //drmModeCrtcPtr crtc = NULL;
    drmModeConnectorPtr connector = NULL;
    uint32_t connector_id = -1;
    uint32_t crtc_id = -1;
    struct buffer_object buf;
    const char * drm_dev_name = "rockchip";

    //打开drm设备
    printf("Try open: %s\n", drm_dev_name);
    int fd = drmOpen("drm_dev_name", "display-subsystem");
    if(fd < 0) {
        perror("open drm device: ");
        printf("Try run 'modetest' for right drm-dev\n");
        return 1;
    }

    //获取crtc,encoder,connector的id
    res = drmModeGetResources(fd);
    if(!res) {
        perror("drmModeGetResources: ");
        goto err;
    }
#ifdef DEBUG
    debugDrmModeRes(res);
#endif

    //获取connector
    for(int i = 0;i < res->count_connectors ;i++) {
        connector = drmModeGetConnector(fd, res->connectors[i]);
        if(connector) {
            if(connector->connection == DRM_MODE_CONNECTED &&
                connector->count_modes > 0){
                connector_id = connector->connector_id;
                crtc_id = res->crtcs[i];
                // drmModeEncoderPtr encoder = drmModeGetEncoder(fd, connector->encoder_id);
                // if(encoder) {
                //  crtc_id = encoder->crtc_id;
                //  drmModeFreeEncoder(encoder);
                // }
                break;
            } else {
                drmModeFreeConnector(connector);
                connector = NULL;
            }
        }
    }

    if(!connector) {
        printf("no connector found!\n");
        goto err;
    }

#ifdef DEBUG
    printf("crtc: \t%d\n", crtc_id);
    printf("connector: \t%d\n", connector_id);
    debugConnector(connector);
#endif

    modeset_create_fb(fd, &buf);
    int mode_index = 3;

    printf("Using connector mode : %s\n", connector->modes[mode_index].name);
    for(int i = 0 ; i < 0xff; i++)
    {
        //绘图
        memset(buf.vaddr, i, buf.size);

        //开始显示
        drmModeSetCrtc(fd, crtc_id, buf.fb_id, 0, 0, &connector_id, 1, &connector->modes[mode_index]);
        break;

    }

    printf("Draw done, press any key to exit\n");
    getchar();

err:
    modeset_destory_fb(fd, &buf);

    if(connector)
        drmModeFreeConnector(connector);

    if(res)
        drmModeFreeResources(res);

    if(fd > 0)
        drmClose(fd);
}
