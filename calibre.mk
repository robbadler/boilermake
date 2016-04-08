CALIBRE_HOME     := /project/dsm/cicd/icf_wg_server/ic/rtc/exports.v2014-1_20-0015-1_engr-$(VCO)/mgc_home
CALIBRE_INCDIRS  := $(CALIBRE_HOME)/shared/pkgs/rtc_inhouse.$(VCO)/include
CALIBRE_INCLUDES := -isystem$(CALIBRE_INCDIRS)
CALIBRE_LIBDIR   := -L$(CALIBRE_HOME)/pkgs/rtc/lib.$(VCO)
CALIBRE_LIB      := -lcalibre_client_oa

