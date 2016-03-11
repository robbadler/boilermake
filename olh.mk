
OLH_DIR      := /wv/synrls/mgc_server/docs/mgc_doc_utils/exports.v4-3_2-1-1002_engr-$(VCO)/mgc_home/shared/pkgs/mgc_doc_utils_inhouse.$(VCO)
OLH_INCDIRS  := $(OLH_DIR)/include/
OLH_INCLUDES := -isystem$(OLH_INCDIRS)
OLH_LIBDIR   := -L$(OLH_DIR)/lib
OLH_LIB      := -lolh_64
