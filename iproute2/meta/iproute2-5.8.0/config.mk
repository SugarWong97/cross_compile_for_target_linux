# Generated config based on /usr/include
# user can control verbosity similar to kernel builds (e.g., V=1)
ifeq ("$(origin V)", "command line")
  VERBOSE = $(V)
endif
ifndef VERBOSE
  VERBOSE = 0
endif
ifeq ($(VERBOSE),1)
  Q =
else
  Q = @
endif

ifeq ($(VERBOSE), 0)
    QUIET_CC       = @echo '    CC       '$@;
    QUIET_AR       = @echo '    AR       '$@;
    QUIET_LINK     = @echo '    LINK     '$@;
    QUIET_YACC     = @echo '    YACC     '$@;
    QUIET_LEX      = @echo '    LEX      '$@;
endif
PKG_CONFIG:=pkg-config
AR:=my_custom_ar
CC:=my_custom_cc
YACC:=bison
TC_CONFIG_NO_XT:=y
IP_CONFIG_SETNS:=y
CFLAGS += -DHAVE_SETNS
HAVE_SELINUX:=n
#LDLIBS += -lselinux
#CFLAGS += -DHAVE_SELINUX
CFLAGS += -DNEED_STRLCPY

%.o: %.c
	$(QUIET_CC)$(CC) $(CFLAGS) $(EXTRA_CFLAGS) $(CPPFLAGS) -c -o $@ $<
