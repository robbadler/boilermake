# Tcl 8.6 export dir
# /net/orw-cicd57-vm/scratch1/continuous_trunk/dev/pxopen_superproj/aoh/Mgc_home/pkgs/tcl86/bin/tclsh8.6
# /net/orw-cicd57-vm/scratch1/continuous_trunk/dev/pxopen_superproj/aoh/Mgc_home/shared/include/tcl8.6
# /net/orw-cicd57-vm/scratch1/continuous_trunk/dev/pxopen_superproj/aoh/Mgc_home/pkgs/tcl86/lib
TCL_HOME := /net/orw-cicd57-vm/scratch1/continuous_trunk/dev/pxopen_superproj/$(VCO)/Mgc_home
TCL_INCDIRS  := $(TCL_HOME)/shared/include/tcl8.6
TCL_INCLUDES := -isystem$(TCL_INCDIRS)
TCL_LIBDIR   := -L$(TCL_HOME)/pkgs/tcl86/lib
TCL_LIB      := -ltcl
