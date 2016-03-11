ifdef MK_OADBG
   OA_TYPE=dbg
else
   OA_TYPE=opt
endif
ifdef MK_USE_DET
   CXXFLAGS := $(CXXFLAGS) -DUSE_DET
endif

ifeq "$(findstring _$(VCO)_,_aof_aog_aoh_aoi_)" "_$(VCO)_"
   OAPLATFORM=linux_rhel40_64
endif

ICFOA_HOME    := /project/dsm/cicd/icf_wg_server/ic/icfoa/exports.v22-43_028-0-1_engr-$(VCO)/mgc_home

ICFOA_INCDIRS := $(ICFOA_HOME)/shared/pkgs/icfoa_inhouse/OA/include/oa \
					  $(ICFOA_HOME)/shared/pkgs/icfoa_inhouse/OA/include/oaLang

ICFOA_INCLUDES := $(addprefix -isystem,$(ICFOA_INCDIR))

ICFOA_LIBDIR := -L$(ICFOA_HOME)/pkgs/icfoa.$(VCO)/OA/lib/linux_rhel40_64/$(OA_TYPE)
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
