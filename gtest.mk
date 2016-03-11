# Google Test install dir
GTEST_HOME := /wv/mgc/mgc_server/ic/googletest/exports.v0-0_11-21-2013_engr-aoh/mgc_home
#GTEST_HOME := /wv/mgc/mgc_server/ic/googletest/exports.v0-0_7-31-2012_engr-aoi/mgc_home

# Compile
GTEST_INCDIRS := $(GTEST_HOME)/shared/pkgs/googletest_inhouse.aoh/include
#GTEST_INCDIRS := $(GTEST_HOME)/shared/pkgs/googletest_inhouse.$(VCO)/include
GTEST_INCLUDES := -isystem$(GTEST_INCDIRS)

# Link
GTEST_LIB := $(GTEST_HOME)/shared/pkgs/googletest_inhouse.aoh/lib/gtest.a
#GTEST_LIB := $(GTEST_HOME)/shared/pkgs/googletest_inhouse.$(VCO)/lib/gtest.a
