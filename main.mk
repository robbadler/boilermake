$(eval $(info Starting GNU make))
$(eval $(info Reading Mentor defs and command flags))

DEFS := IC_ISO14882 \
		  __STDC_LIMIT_MACROS \
		  ANSI_STREAMS_SUPPORT \
		  SERIALIZATION
#DEFS := \
		  IC_64BIT \
		  ICFLOW \
		  DMREV=4 \
		  THREADS \
		  QT_FATAL_ASSERT \
		  QT_THREAD_SUPPORT \
		  __STDC_FORMAT_MACROS \
		  vco_aoi \
		  BETA_NOTICE \
		  TIMEBOMB \
		  INTERNAL_IP \
		  USE_DET \
		  MEMDBG \

DISTCC_BIN = /project/dsm/cicd/tools/Distcc/aof/distcc-3.1/bin/distcc
NO_DISTCC ?= 0
ifeq ($(NO_DISTCC), 1)
DISTCC_BIN =
endif

CCACHE_BIN = /home/rhoughto/local/bin/ccache

PREFIX_CMD = $(CCACHE_BIN)
USE_CCACHE ?= 0
ifeq ($(USE_CCACHE), 0)
PREFIX_CMD = $(DISTCC_BIN)
endif

NOQUIET ?= 0
ifeq ($(NOQUIET), 1)
QUIET :=
endif

CXX = /project/dsm/cicd/tools/color_compile/bin/c++
#CXX := /usr/bin/c++

CXXFLAGS := -fPIC -msse2 -mfpmath=sse -Wno-deprecated -pthread -Wno-attributes
CXXFLAGS_DBG := -g -DDEBUG
CXXFLAGS_OPT := -O3

MEMDBG ?= 0
ifeq ($(MEMDBG), 1)
CXXFLAGS      += -DMEMDBG
SRC_MOC_FLAGS += -DMEMDBG
endif

DEBUG ?= 0
ifeq ($(DEBUG), 1)
CXXFLAGS += $(CXXFLAGS_DBG)
endif

OPT ?= 1
ifeq ($(OPT), 1)
CXXFLAGS += $(CXXFLAGS_OPT)
endif

AR = /usr/bin/ar
ARFLAGS := rc

#CXXFLAGS += \
				-Wall -Wsynth -fcheck-new -fno-strict-aliasing -fmessage-length=1024 \
				-Wno-ctor-dtor-privacy -Wno-non-virtual-dtor -Wno-unused -fno-omit-frame-pointer \
				-Wno-long-long

#BUILD_DIR := /net/swallow/scratch1/iwa/osprey/nonRecursiveMake/boilermake/aoi

ROOT := $(abspath ..)
CWD := $(addsuffix /,$(shell pwd))

BUILD_DIR := build
BUILD_DIR := $(addprefix ${CWD},${BUILD_DIR})

EXPORT_DIR_BASE := $(MGC_HOME)/lib
#TARGET_DIR := /net/swallow/scratch1/iwa/osprey/nonRecursiveMake/boilermake/targs
LDFLAGS :=	-L. \
				-L$(MGC_HOME)/../exports/mgc_home/pkgs/pdk.$(VCO)/lib/pdk \
            -Wl,-rpath-link=. \
            -Wl,-rpath-link=$(MGC_HOME)/../exports/mgc_home/pkgs/pdk.$(VCO)/lib/pdk

## HOWTO DET EXPORT
#link_pkg_vco -src exports/mgc_home
#link_mgc -silent -include -pkg `/usr/mgc/bin/get_pkgs exports/mgc_home`

## Comment the next line to auto-remove generated files
#.SECONDARY:

$(eval $(info Adding root SUBMAKEFILE))
SUBMAKEFILES := ${ROOT}/src.mk


# INTERMEDIATE keyword is broken on make 3.81. It also makes targets .PRECIOUS
# NOTE: intermediate must take full files, not patterns
#.INTERMEDIATE:

# MOC Rules
MOC = $(MGC_HOME)/bin/moc

# LEX Rules
LEX = /project/dsm/cicd/tools/Flex-2.5.35/aof/flex-2.5.35/bin/flex

# YACC
YACC = /project/dsm/cicd/tools/bison/aof/bison-2.5/bin/bison

# SWIG
SWIG = /project/dsm/cicd/tools/SWIG/swig-2.0.7_installed/bin/swig

# RCC
RCC = $(MGC_HOME)/bin/rcc

# Qt UIC
UIC = $(MGC_HOME)/bin/uic

# Router Interface Generator
IFGEN = $(MGC_HOME)/bin/ifgen

# Router Header Generator
PROPGEN = $(MGC_HOME)/bin/xml2h.pl

# Router Message Generator
MSGGEN = $(MGC_HOME)/bin/xml2msg.pl

# CoreGeom from Infrastructure (temp)
include coreGeom.mk

# Cryptopp
include cryptopp.mk

# PYTHON
include python.mk

# OpenAccess
include icfoa.mk

# QT
include qt4.mk

# LOG4CXX
include log4cxx.mk

# BOOST
include boost.mk

# TCL
include tcl.mk

# MGLS
include mgls.mk

# OLH
include olh.mk

# RealTime Calibre
include rtc.mk

# Calibre Client
include calibre.mk

# FLEX
include flex.mk

# YAML
include yaml.mk

# TAO
include tao.mk

# PETSC
include petsc.mk

INCDIRS := \
			  $(QT_INCDIRS) \
			  $(LOG4CXX_INCDIRS) \
			  $(ICFOA_INCDIRS) \
			  $(BOOST_INCDIRS) \
			  $(PYTHON_INCDIRS) \
			  /project/dsm/cicd/tools/pyxis/loki-0.1.7/include/loki \
			  $(MGC_HOME)/shared/include
#			  $(MGC_HOME)/shared/include/DomainAPI

$(eval $(info Done reading main.mk))
