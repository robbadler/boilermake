PDK_HOME ?= /wv/icbld8/icfw_wg_server/cicd/pdk/exports.v1-0_0-3-1_engr-$(VCO)/mgc_home
PDK_INCDIRS = $(PDK_HOME)/shared/pkgs/pdk_inhouse.$(VCO)/include
PDK_LIBDIR =  -L$(PDK_HOME)/pkgs/pdk.$(VCO)/lib/pdk
PDK_LIB = -lpdk_coregeom
#-loap_dbSkill
#-loap_db
#-loap_slSkill
#-loap_sl
#-loap_techscripting
#-loap_techSkill
#-lrod_skl
#-lrod
#-lsps
#-ltechManager
