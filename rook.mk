#
# Because rook/export.sh can do "an export" to the local
# directory, once the building of a local work area succeeds
# that work area contains a directory structure matching
# that which would be imported. Thus, when debugging a problem
# in Rook by way of Skua, one can "hot import" the Rook
# work area, e.g.:
#   ROOK_HOME=/net/bokeh/scratch1/rei/rook
#   export ROOK_HOME
#
ROOK_HOME ?= /wv/sarge/exports/rook_1_3_3.$(VCO)
ROOK_INCDIRS = $(ROOK_HOME)/include
ROOK_LIBDIR =  -L$(ROOK_HOME)/lib
ROOK_LIB = -lrook
