host平台　　 ：Ubuntu 16.04

arm平台　　 ： 3531d (Linux 3.18)

 

[ntfs-3g](https://www.tuxera.com/community/open-source-ntfs-3g/)　　　：2017.3.23


arm-gcc　　 ：4.9.4

## 内核支持

1）支持USB HDD，在内核配置中选上（为了支持USB移动硬盘）

```
Device Drivers —
   SCSI device support —
     * SCSI disk support
     [*] SCSI low-level drivers —
```

 

2）支持NTFS格式，在内核配置中选上

```
File systems —
　　DOS/FAT/NT Filesystems —
　　* NTFS file system support
　　[*] NTFS write support
[*]  FUSE (Filesystem in Userspace) support
```

 

3）（可选）需要支持中文字符，则需要在内核配置中选上

```
File systems —
   -*- Native language support —
   * NLS UTF-8
```

 



 

 

## 主机准备：
移植ntfs-3g 以支持写ntfs

### 使用以下脚本进行编译



```
##
#    Copyright By Schips, All Rights Reserved

BUILD_HOST=arm-linux
BASE=`pwd`
OUTPUT_PATH=${BASE}/install

make_dirs () {
    #为了方便管理，创建有关的目录
    cd ${BASE} && mkdir compressed install source -p
}

tget () { #try wget
    filename=`basename $1`
    echo "Downloading [${filename}]..."
    if [ ! -f ${filename} ];then
        wget $1
    fi

    echo "[OK] Downloaded [${filename}] "
}

tar_package () {
    cd ${BASE}/compressed
    ls * > /tmp/list.txt
    for TAR in `cat /tmp/list.txt`
    do
        tar -xf $TAR -C  ../source
    done
    rm -rf /tmp/list.txt
}
download_package () {
    cd ${BASE}/compressed
    tget https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2017.3.23.tgz
}

make_ntfs3g () {
    cd ${BASE}/source/ntfs-3g*
    ./configure --host=${BUILD_HOST} \
    CC=${BUILD_HOST}-gcc   AR=${BUILD_HOST}-ar  \
    --prefix=${OUTPUT_PATH}/ntfs-3g/usr
    make 
    mkdir ${OUTPUT_PATH}/ntfs-3g -p
    mkdir ${OUTPUT_PATH}/ntfs-3g/sbin -p
    mkdir ${OUTPUT_PATH}/ntfs-3g/lib -p
    cp ${BASE}/source/ntfs-3g*/ntfsprogs/ntfsfix   ${OUTPUT_PATH}/ntfs-3g/sbin -v
    cp ${BASE}/source/ntfs-3g*/src/.libs/ntfs-3g   ${OUTPUT_PATH}/ntfs-3g/sbin -v

    cp ${BASE}/source/ntfs-3g*/libntfs-3g/.libs/libntfs-3g.so*  ${OUTPUT_PATH}/ntfs-3g/lib -v
}

make_dirs
download_package
tar_package
make_ntfs3g

echo <<EOF

得到： ntfs-3g（${OUTPUT_PATH}/bin） 以及 libntfs-3g.so.0.0.0 （${OUTPUT_PATH}/lib）
拷贝到对应的arm板目录中即可
EOF
```



 

### 测试：

```
ntfs-3g -o silent /dev/sda1 /mnt/sd
```


## 附录： 关于自动挂载USB移动硬盘



```
嵌入式linux 使用mount -t ntfs-3g /dev/sda /mnt命令错误
 
Q:
使用ntfs-3g /dev/sda /mnt 挂载U盘成功。
但使用 mount -t ntfs-3g /dev/sda /mnt命令则提示 no such device。
busybox 版本为1.11.1， kernel版本 2.6.27.39
 
A1:
这个就不知道了，我看过好几个嵌入式系统自动挂载都是判断如果是ntfs格式使用ntfs-3g命令来挂载的，在pc机上是可以用mount -t ntfs-3g的，应该是busybox不支持的原因吧。
 
A2:
busybox不支持，在应用程序中调用mount函数时，fstype参数应该也认不出来吧；要不就是这个命令在busybody上支持的不是太完善
```



 

自动挂载有关文章：《[Linux-实现U盘自动挂载(详解)](https://www.cnblogs.com/lifexy/p/7891883.html)》

实现思路：

1）根据/etc/udev/udev.conf找到规则文件所在的文件夹（需要busybox支持udev）

2）找到实际运行的规则和脚本

3）修改添加对ntfs的支持即可

 

以下是一个支持ntfs挂载/卸载 一体化的脚本



```
#!/bin/sh

# Called from udev
# Attempt to mount any added block devices and umount any removed devices

MOUNT_PATH="/media"
MOUNT="/bin/mount"
PMOUNT="/usr/bin/pmount"
UMOUNT="/bin/umount"

# FOR NTFS
NTFS="/usr/bin/ntfs-3g"

for line in `cat /etc/udev/mount.blacklist`
do

        if [ ` expr match "$DEVNAME" "$line" ` -gt 0 ];
        then
                logger "udev/mount.sh" "[$DEVNAME] is blacklisted, ignoring"
                exit 0
        fi

done


automount() {

        name="`basename "$DEVNAME"`"

        ! test -d "${MOUNT_PATH}/${name}" && mkdir -p "${MOUNT_PATH}/${name}"

        if $MOUNT -t auto  $DEVNAME "${MOUNT_PATH}/${name}"
        then

                logger "mount.sh/automount" "Auto-mount of [${MOUNT_PATH}/${name}] successful"
                touch "/tmp/.automount-$name"

        elif $NTFS $DEVNAME "${MOUNT_PATH}/${name}"
        then

                logger "mount.sh/ntfs-3g" "Auto-mount of [${MOUNT_PATH}/${name}] successful"
                touch "/tmp/.automount-$name"

        else

                #logger "mount.sh/automount" "$MOUNT -t auto $DEVNAME \"${MOUNT_PATH}/${name}\" failed!"
                rm_dir "${MOUNT_PATH}/${name}"

        fi
}


rm_dir() {

        # We do not want to rm -r populated directories

        if test "`find "$1" | wc -l | tr -d " "`" -lt 2 -a -d "$1"

        then

                ! test -z "$1" && rm -r "$1"
        else

                logger "mount.sh/automount" "Not removing non-empty directory [$1]"
        fi

}


if [ "$ACTION" = "add" ] && [ -n "$DEVNAME" ]; then

        if [ -x "$PMOUNT" ]; then

                $PMOUNT $DEVNAME 2> /dev/null

        elif [ -x $MOUNT ]; then

                $MOUNT $DEVNAME 2> /dev/null

        fi

        # If the device isn't mounted at this point, it isn't configured in fstab

        grep -q "^$DEVNAME " /proc/mounts || automount

fi


if [ "$ACTION" = "remove" ] && [ -x "$UMOUNT" ] && [ -n "$DEVNAME" ]; then

        for mnt in `cat /proc/mounts | grep "$DEVNAME" | cut -f 2 -d " " `

        do
                $UMOUNT $mnt
        done

        # Remove empty directories from auto-mounter

        name="`basename "$DEVNAME"`"

        test -e "/tmp/.automount-$name" && rm_dir "${MOUNT_PATH}/${name}"

fi
```

 
