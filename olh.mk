# On-Line-Help
OLH_HOME     := /wv/synrls/mgc_server/docs/mgc_doc_utils/exports.v4-3_2-1-1002_engr-$(VCO)/mgc_home
OLH_INCDIRS  := $(OLH_HOME)/shared/pkgs/mgc_doc_utils_inhouse.$(VCO)/include/
OLH_INCLUDES := -isystem$(OLH_INCDIRS)
OLH_LIBDIR   := -L$(OLH_HOME)/shared/pkgs/mgc_doc_utils.$(VCO)/lib
OLH_LIB      := -lolh_64
