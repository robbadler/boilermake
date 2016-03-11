# When changing this file, ensure that ../App/rook.sh is updated with the same values.

# Python export dir
PYTHON_HOME := /project/dsm/cicd/icf_wg_server/ic/python/exports.v1-0_0-0-5_engr-$(VCO)/mgc_home
PYTHON_INCDIRS  := $(PYTHON_HOME)/pkgs/python.$(VCO)/include/python2.6
PYTHON_INCLUDES := -isystem$(PYTHON_INCDIRS)
PYTHON_LIBDIR   := -L$(PYTHON_HOME)/pkgs/python.$(VCO)/lib
PYTHON_LIB      := -lpython2.6
