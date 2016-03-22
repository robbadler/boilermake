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
LOON_HOME ?= /wv/sarge/exports/loon_1_3_5.$(VCO)
LOON_INCDIRS = $(LOON_HOME)/include
LOON_LIBDIR =  -L$(LOON_HOME)/lib
LOON_LIB = -lloon
