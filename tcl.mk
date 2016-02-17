TCL_INCDIRS  := $(MGC_HOME)/shared/pkgs/tcl86_inhouse/include/tcl8.6
TCL_INCLUDES := -isystem$(TCL_INCDIRS)
TCL_LIBDIR   := -L$(MGC_HOME)/pkgs/tcl86/lib
TCL_LIB      := -ltcl8.6
