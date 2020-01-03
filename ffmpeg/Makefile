# 	    Makefile edited by Schips
# 	    2019-06-21 schips@dingtalk.com

# 文件类型
PSFS		=.cpp

# 源文件所在目录
SRC_LIST    = .
# 头文件所在目录
INCLUDE		= include

# 编译选项
CFLAGS	    = -g -Wall 
CC			= g++
CXX			= g++


# 库路径
LDLIBS		= ./lib

# 库名
#LIBS 		= avutil avcodec avdevice avfilter swscale swresample avformatis 
LIBS 		= avutil avcodec avdevice avfilter swscale swresample avformat  x264 postproc

# 调试用
#INSIGHT 	= gdb

# 输出文件名
TGT         = demo
OTHER_CSRC  = 
OTHER_ASRC  = 
ASRC        = 

########################################
# 不需要改动
INC_P = -I 
LIBD_P = -L 
LIB_P = -l
CFLAGS      += $(addprefix $(INC_P), $(INCLUDE)) 
LDFLAGS     += $(addprefix $(LIBD_P), $(LDLIBS)) 
LIB_ALL     += $(addprefix $(LIB_P), $(LIBS)) 
SRC_LIST	?= .
SRCSS		+= $(addsuffix /*$(PSFS), $(SRC_LIST)) 
CSRC        += $(wildcard  $(SRCSS))

OBJS        = $(CSRC:$(PSFS)=.o) $(ASRC:.S=.o)
NOLINK_OBJS = $(OTHER_CSRC:$(PSFS)=.o) $(OTHER_ASRC:.S=.o)
DEPS        = $(OBJS:.o=.d) $(NOLINK_OBJS:.o=.d)
BIN         = $(TGT)

.PHONY: clean all

all: $(BIN)

$(BIN): $(OBJS) $(NOLINK_OBJS)
	$(CC) $(LDFLAGS) $(OBJS) $(LIB_ALL) -o $@

clean:
	rm -f $(DEPS)
	rm -f $(OBJS) $(NOLINK_OBJS) 
	rm -f $(BIN)

# ---------------------------------------------------------------------------
# rules for code generation
# ---------------------------------------------------------------------------
%.o:    %$(PSFS)
	$(CC) $(CFLAGS) -o $@ -c $<

%.o:    %.S
	$(CC) $(ASFLAGS) -o $@ -c $<

# ---------------------------------------------------------------------------
#  # compiler generated dependencies
# ---------------------------------------------------------------------------
-include $(LWOS_DEPS) $(PORT_DEPS) $(APPL_DEPS)

