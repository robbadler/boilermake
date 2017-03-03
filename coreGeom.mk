CORE_GEOM_HOME     := /project/dsm/cicd/icf_wg_server/cicd/cgeom/exports.v1-0_0-0-2_engr-$(VCO)/mgc_home

CORE_GEOM_INCDIRS  := $(CORE_GEOM_HOME)/shared/pkgs/cgeom_inhouse.$(VCO)/include
CORE_GEOM_INCLUDES := -isystem$(CORE_GEOM_INCDIRS)
CORE_GEOM_LIBDIR   := -Wl,-rpath-link=$(CORE_GEOM_HOME)/pkgs/cgeom.$(VCO)/lib/cgeom \
                      -L$(CORE_GEOM_HOME)/pkgs/cgeom.$(VCO)/lib/cgeom
CORE_GEOM_LIB := -loap_coregeom

CORE_GEOM_RPATH := -Wl,-rpath=$(CORE_GEOM_HOME)/pkgs/cgeom.$(VCO)/lib/cgeom

