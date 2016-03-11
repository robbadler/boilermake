$(eval $(info Starting GNU make))
$(eval $(info Reading Mentor defs and command flags))

DISTCC_BIN = /project/dsm/cicd/tools/Distcc/aof/distcc-3.1/bin/distcc
NO_DISTCC ?= 1
ifeq ($(NO_DISTCC), 1)
DISTCC_BIN =
endif

CCACHE_BIN = /home/rhoughto/local/bin/ccache

PREFIX_CMD = $(CCACHE_BIN)
USE_CCACHE ?= 0
ifeq ($(USE_CCACHE), 0)
PREFIX_CMD = $(DISTCC_BIN)
endif

Q :=@
QUIET ?= 1
ifeq ($(QUIET), 0)
Q :=
endif

CXX = /project/dsm/cicd/tools/color_compile/bin/c++

ifeq ($(strip $(CXXFLAGS)),"")
override CXXFLAGS := -fPIC -msse2 -mfpmath=sse -pthread
else
override CXXFLAGS := $(CXXFLAGS) -fPIC -msse2 -mfpmath=sse -pthread
endif


EXTERNAL ?= 0
ifneq ($(EXTERNAL), 1)
override CXXFLAGS += -DINTERNAL_IP
endif

CXXFLAGS_DBG := -g -DDEBUG
CXXFLAGS_OPT := -O4

MEMDBG ?= 0
ifeq ($(MEMDBG),1)
override CXXFLAGS      += -DMEMDBG
SRC_MOC_FLAGS += -DMEMDBG
endif

DEBUG ?= 0
ifeq ($(DEBUG),1)
override CXXFLAGS += $(CXXFLAGS_DBG)
endif

OPT ?= 1
ifeq ($(OPT),1)
override CXXFLAGS += $(CXXFLAGS_OPT)
endif

AR = /usr/bin/ar
ARFLAGS := rc

ROOT := $(abspath ..)
CWD := $(addsuffix /,$(shell pwd))

# BUILD_DIR is rooted to the current source dir
BUILD_DIR := objs

# ${TGT}_EXPORTDIR and ${TGT}_TGTDIR are rooted relative to the paths below, from the build dir (boilermake)
EXPORT_DIR_BASE := .
TARGET_DIR_BASE := .
LDFLAGS :=	-L.

## Comment the next line to auto-remove generated files
#.SECONDARY:

$(eval $(info Adding root SUBMAKEFILE))
SUBMAKEFILES := ${ROOT}/root.mk


# INTERMEDIATE keyword is broken on make 3.81. It also makes targets .PRECIOUS
# FIXED in make 3.82
##.INTERMEDIATE: %pywrap.cxx %wrap.cxx

# MGLS
include mgls.mk

# OLH
include olh.mk

$(eval $(info Done reading main.mk))




