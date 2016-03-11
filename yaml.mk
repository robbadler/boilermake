
YAML_HOME    := /project/dsm/cicd/icf_wg_server/cicd/yaml/exports.v0-3_0-0-2_engr-$(VCO)/mgc_home

YAML_INCDIRS := $(YAML_HOME)/shared/pkgs/yaml_inhouse.$(VCO)/include

YAML_LIBDIR := -L$(YAML_HOME)/pkgs/yaml/lib.$(VCO)

YAML_LIB := -lyaml-cpp
