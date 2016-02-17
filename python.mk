ifneq "$(PYTHON_VERSION)" "2.5"
   PYTHON_HOME = $(MGC_HOME)/pkgs/python
   PYTHON_VERSION = 2.6
   PKG_VER =
   # Python interface generation with SWIG (for Osprey)
   CLASSIC=
else
   PYTHON_HOME = $(MGC_HOME)/pkgs/python25/python
   PYTHON_VERSION = 2.5
   PKG_VER = 25
   # Python interface generation with SWIG (for Osprey)
   CLASSIC=-classic
endif
PYTHON_INCDIRS  := $(PYTHON_HOME)/include/python$(PYTHON_VERSION)
PYTHON_INCLUDES := -isystem$(PYTHON_INCDIRS)
PYTHON_LIBDIR   := -L$(PYTHON_HOME)/lib
PYTHON_LIB      := -lpython$(PYTHON_VERSION)
