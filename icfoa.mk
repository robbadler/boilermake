ifdef MK_OADBG
   OA_TYPE=dbg
else
   OA_TYPE=opt
endif
ifdef MK_USE_DET
   CXXFLAGS := $(CXXFLAGS) -DUSE_DET
endif

ifeq "$(findstring _$(VCO)_,_aof_aog_aoi_)" "_$(VCO)_"
   OAPLATFORM=linux_rhel40_64
endif

ICFOA_INCDIRS := $(MGC_HOME)/shared/pkgs/icfoa_inhouse/OA/include/oa \
					  $(MGC_HOME)/shared/pkgs/icfoa_inhouse/OA/include/oaLang

ICFOA_INCLUDES := $(addprefix -isystem,$(ICFOA_INCDIR))

ICFOA_LIBDIR := -L$(MGC_HOME)/pkgs/icfoa/OA/lib/linux_rhel40_64/$(OA_TYPE)
ICFOA_FULL_LIB :=	-loaBase \
			-loaCommon \
			-loaDM \
			-loaTech \
			-loaDesign \
			-loaPlugIn \
			-loaWafer
ICFOA_LANG_LIB :=	-loaLangBase \
			-loaLangInfo \
			-loaTclCommon
ICFOA_TCL_LIB :=	-loaTclPlugIn \
			-loaTclBase \
			-loaTclCommon \
			-loaTclHelp \
			-loaTcl
