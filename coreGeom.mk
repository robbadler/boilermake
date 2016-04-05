
CORE_GEOM_INCDIRS  := $(MGC_HOME)/shared/pkgs/cgeom_inhouse.$(VCO)/include
CORE_GEOM_INCLUDES := -isystem$(CORE_GEOM_INCDIRS)
CORE_GEOM_LIBDIR   := -L$(MGC_HOME)/pkgs/cgeom.$(VCO)/lib/cgeom
CORE_GEOM_LIB := -loap_coregeom
#-loap_oa_utils -loap_instancestack -loap_executor
