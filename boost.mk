
BOOST_BASEDIR := /project/dsm/cicd/icf_wg_server/fw_ic/boost/exports.v1-49_0-0-1_engr-$(VCO)/mgc_home

BOOST_INCDIRS := $(BOOST_BASEDIR)/shared/pkgs/boost_inhouse.$(VCO)/boost_ext/include

BOOST_INCLUDES := -isystem$(BOOST_INCDIRS)

BOOST_LIBDIR := -Wl,-rpath-link=$(BOOST_BASEDIR)/pkgs/boost.$(VCO)/lib -L$(BOOST_BASEDIR)/pkgs/boost.$(VCO)/lib

BOOST_RPATH := -Wl,-rpath=$(BOOST_BASEDIR)/pkgs/boost.$(VCO)/lib

