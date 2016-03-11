RTC_HOME     := /project/dsm/cicd/icf_wg_server/ic/rtc/exports.v2014-1_20-0015-1_engr-$(VCO)/mgc_home
RTC_INCDIRS  := $(RTC_HOME)/shared/pkgs/rtc_inhouse.$(VCO)/include
RTC_INCLUDES := -isystem$(RTC_INCDIRS)
RTC_LIBDIR := -L$(RTC_HOME)/pkgs/rtc/lib.$(VCO)
