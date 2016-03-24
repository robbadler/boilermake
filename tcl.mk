TCL_VERSION ?= 8.6
ifeq ($(TCL_VERSION), 8.4)
# Tcl 8.4 export dir
TCL_HOME := /wv/mgc/mgc_server/ic/comp/exports.v0-0_11-25-2015_engr-$(VCO)/mgc_home/shared/pkgs/icv_comp_inhouse.$(VCO)/8.4
TCL_INCDIRS  := $(TCL_HOME)/include/generic
TCL_INCLUDES := -isystem$(TCL_INCDIRS)
TCL_LIBDIR   := -L$(TCL_HOME)/lib
TCL_LIB      := -ltcl
else
# Tcl 8.6 export dir
TCL_HOME := /project/dsm/cicd/icf_wg_server/ic/tcl86/exports.v8-6_0-0-1_engr-$(VCO)/mgc_home
TCL_INCDIRS  := $(TCL_HOME)/shared/pkgs/tcl86_inhouse.$(VCO)/include/tcl8.6
TCL_INCLUDES := -isystem$(TCL_INCDIRS)
TCL_LIBDIR   := -L$(TCL_HOME)/pkgs/tcl86.$(VCO)/lib
TCL_LIB      := -ltcl
endif
