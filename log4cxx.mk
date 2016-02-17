

## External OpenSource Includes
LOG4CXX_INCDIRS  := $(MGC_HOME)/shared/pkgs/log4cxx_inhouse/include
LOG4CXX_INCLUDES := -isystem$(LOG4CXX_INCDIRS)
LOG4CXX_LIBDIR   := -L$(MGC_HOME)/pkgs/log4cxx/lib
LOG4CXX_LIB      := -llog4cxx -lapr-1 -laprutil-1
