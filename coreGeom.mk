
CORE_GEOM_INCDIRS  := $(MGC_HOME)/shared/include/InfrastructureAPI/
CORE_GEOM_INCLUDES := -isystem$(CORE_GEOM_INCDIRS)
CORE_GEOM_LIBDIR   := -L$(MGC_HOME)/pkgs/infrastructure/lib/Infrastructure
CORE_GEOM_LIB := -loap_coregeom
#-loap_oa_utils -loap_instancestack -loap_executor
