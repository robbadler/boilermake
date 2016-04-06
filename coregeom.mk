COREGEOM_HOME ?= /wv/icbld8/icfw_wg_server/cicd/cgeom/exports.v1-0_0-0-1_engr-$(VCO)/mgc_home
COREGEOM_INCDIRS = $(COREGEOM_HOME)/shared/pkgs/cgeom_inhouse.$(VCO)/include
COREGEOM_LIBDIR =  -L$(COREGEOM_HOME)/pkgs/cgeom.$(VCO)/lib/cgeom
COREGEOM_LIB = -loap_coregeom
