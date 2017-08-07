ifeq ($(VCO),aoi)
TCL_HOME     := /project/dsm/cicd/icf_wg_server/ic/tcl86/exports.v8-6_0-0-2_engr-$(VCO)/mgc_home
else
TCL_HOME     := /project/dsm/cicd/icf_wg_server/ic/tcl86/exports.v8-6_0-0-1_engr-$(VCO)/mgc_home
endif

TCL_INCDIRS  := $(TCL_HOME)/shared/pkgs/tcl86_inhouse.$(VCO)/include/tcl8.6
TCL_INCLUDES := -isystem$(TCL_INCDIRS)
TCL_LIBDIR   := -Wl,-rpath-link=$(TCL_HOME)/pkgs/tcl86.$(VCO)/lib \
                              -L$(TCL_HOME)/pkgs/tcl86.$(VCO)/lib
TCL_LIB      := -ltcl8.6

TCL_RPATH := -Wl,-rpath=$(TCL_HOME)/pkgs/tcl86.$(VCO)/lib
