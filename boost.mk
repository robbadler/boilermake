ifeq "$(findstring _$(VCO)_,_aoi_)" "_$(VCO)_"
   BOOST_HOME=/wv/mgc/mgc_server/ic/boost/exports.v1.43_4-28-2014_engr-$(VCO)/mgc_home
else
   BOOST_HOME=/wv/mgc/mgc_server/ic/boost/exports.v1.43_4-28-2014_engr-any/mgc_home
endif

BOOST_INCDIRS := $(BOOST_HOME)/shared/pkgs/boost_inhouse.any/include
BOOST_INCLUDES := -isystem$(BOOST_INCDIRS)
