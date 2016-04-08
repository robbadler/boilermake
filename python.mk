ifeq "$(PYTHON_VERSION)" "2.5"
   PYTHON_HOME = $(MGC_HOME)/pkgs/python25/python
   PYTHON_HOME = /project/dsm/cicd/icf_wg_server/cicd/python25/exports.v2-5_1-0-1_engr-$(VCO)/mgc_home/pkgs/python25.$(VCO)/python
   PYTHON_VERSION = 2.5
   PKG_VER = 25
   # Python interface generation with SWIG (for Osprey)
   CLASSIC=-classic
else
   PYTHON_HOME = /project/dsm/cicd/icf_wg_server/ic/python/exports.v1-0_0-0-5_engr-$(VCO)/mgc_home/pkgs/python.$(VCO)
   PYTHON_VERSION = 2.6
   PKG_VER =
   # Python interface generation with SWIG (for Osprey)
   CLASSIC=
endif
PYTHON_INCDIRS  := $(PYTHON_HOME)/include/python$(PYTHON_VERSION)
PYTHON_INCLUDES := -isystem$(PYTHON_INCDIRS)
PYTHON_LIBDIR   := -L$(PYTHON_HOME)/lib
PYTHON_LIB      := -lpython$(PYTHON_VERSION)
