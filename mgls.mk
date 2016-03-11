# MGLS export dir
MGLS_HOME := /wv/mgc/mgc_server/fw/mgls/exports.v9-11_3-4-0_engr-$(VCO)/mgc_home/

MGLS_INCDIRS  := $(MGLS_HOME)/shared/pkgs/mgls_inhouse.$(VCO)/include
MGLS_INCLUDES := -isystem$(MGCLS_INCDIRS)
MGLS_LIBDIR   := -L$(MGLS_HOME)/shared/pkgs/mgls_inhouse.$(VCO)/lib
MGLS_LIB      := -lmgls_64
