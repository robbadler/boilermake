
BOOST143 ?= 0
ifeq ($(BOOST143), 0)
# Default. Boost 149... (Wish it was a little bit newer, but PyxisOpen decides...
BOOST_BASEDIR := /wv/mgc/mgc_server/fw_ic/boost/exports.v1-49_0-0-1_engr-$(VCO)/mgc_home
else
# Pyxis ICStation
BOOST_BASEDIR := /wv/mgc/mgc_server/fw_ic/boost/exports.v1-43_0-0-1_engr-$(VCO)/mgc_home
endif

BOOST_INCDIRS := $(BOOST_BASEDIR)/shared/pkgs/boost_inhouse.$(VCO)/boost_ext/include

BOOST_INCLUDES := -isystem$(BOOST_INCDIRS)

BOOST_LIBDIR := -Wl,-rpath-link=$(BOOST_BASEDIR)/pkgs/boost.$(VCO)/lib -L$(BOOST_BASEDIR)/pkgs/boost.$(VCO)/lib

BOOST_RPATH := -Wl,-rpath=$(BOOST_BASEDIR)/pkgs/boost.$(VCO)/lib

