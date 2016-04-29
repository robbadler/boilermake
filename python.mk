ifeq ($(PYTHON_VERSION), 2.6)
# Python 2.6 export dir
PYTHON_HOME := /project/dsm/cicd/icf_wg_server/ic/python/exports.v1-0_0-0-5_engr-$(VCO)/mgc_home
PYTHON_INCDIRS  := $(PYTHON_HOME)/pkgs/python.$(VCO)/include/python2.6
PYTHON_INCLUDES := -isystem$(PYTHON_INCDIRS)
PYTHON_LIBDIR   := -L$(PYTHON_HOME)/pkgs/python.$(VCO)/lib
PYTHON_LIB      := -lpython2.6
else
# Python 3 export dir
PYTHON_HOME := /wv/sarge/Python-3.5.1
PYTHON_INCDIRS  := $(PYTHON_HOME)/include
PYTHON_INCLUDES := -isystem$(PYTHON_INCDIRS)
PYTHON_LIBDIR   := -L$(PYTHON_HOME)/lib
PYTHON_LIB      := -lpython3.5m
endif
