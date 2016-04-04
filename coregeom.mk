COREGEOM_HOME ?= /wv/icfbld/builds/TOT/Rook/CoreGeom/dev/cicd/cgeom/$(VCO)/exports/mgc_home
COREGEOM_INCDIRS = $(COREGEOM_HOME)/shared/pkgs/cgeom_inhouse.$(VCO)/include
COREGEOM_LIBDIR =  -L$(COREGEOM_HOME)/pkgs/cgeom.$(VCO)/lib/cgeom
COREGEOM_LIB = -loap_coregeom
