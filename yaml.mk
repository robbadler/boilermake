YAML_HOME     := /project/dsm/cicd/icf_wg_server/cicd/yaml/exports.v0-3_0-0-2_engr-$(VCO)

YAML_INCDIRS  := $(YAML_HOME)/shared/pkgs/yaml_inhouse.$(VCO)/include
YAML_INCLUDES := -isystem$(YAML_INCDIRS)

YAML_LIBDIR := -L$(YAML_HOME)/pkgs/yaml.$(VCO)/lib

YAML_LIB := -lyaml-cpp
