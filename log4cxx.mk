
LOG4CXX_HOME := /project/dsm/cicd/icf_wg_server/cicd/log4cxx/exports.v1-0_0-0-2_engr-$(VCO)/mgc_home
## External OpenSource Includes
LOG4CXX_INCDIRS  := $(LOG4CXX_HOME)/shared/pkgs/log4cxx_inhouse.$(VCO)/include
LOG4CXX_INCLUDES := -isystem$(LOG4CXX_INCDIRS)
LOG4CXX_LIBDIR   := -L$(LOG4CXX_HOME)/pkgs/log4cxx.$(VCO)/lib
LOG4CXX_LIB      := -llog4cxx -lapr-1 -laprutil-1
