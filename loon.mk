#
# Because loon/export.sh can do "an export" to the local
# directory, once the building of a local work area succeeds
# that work area contains a directory structure matching
# that which would be imported. Thus, when debugging a problem
# in Loon by way of Skua, one can "hot import" the Loon
# work area, e.g.:
#   LOON_HOME=/net/bokeh/scratch1/rei/loon
#   export LOON_HOME
#
LOON_HOME ?= /wv/sarge/exports/loon_1_4_1.$(VCO)
LOON_INCDIRS = $(LOON_HOME)/mgc_home/shared/pkgs/loon_inhouse.$(VCO)/include
LOON_LIBDIR =  -L$(LOON_HOME)/mgc_home/pkgs/loon.$(VCO)/lib
LOON_LIB = -lloon
