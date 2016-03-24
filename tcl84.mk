# Tcl 8.4 export dir
TCL_HOME := /wv/mgc/mgc_server/ic/comp/exports.v0-0_11-25-2015_engr-$(VCO)/mgc_home/shared/pkgs/icv_comp_inhouse.$(VCO)/8.4
TCL_INCDIRS  := $(TCL_HOME)/include/generic
TCL_INCLUDES := -isystem$(TCL_INCDIRS)
TCL_LIBDIR   := -L$(TCL_HOME)/lib
TCL_LIB      := -ltcl
