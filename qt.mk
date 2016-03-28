QT_VERSION ?= 4
ifneq ($(QT_VERSION), 5)
# Qt install dir
QT_HOME := /wv/ic_wg_server/ic/qt/exports.v0-0_3-10-2015_engr-$(VCO)/mgc_home

# Qt binaries
QT_BIN := $(QT_HOME)/shared/pkgs/icv_qt_comp_inhouse.$(VCO)/bin

# Compile
QT_INCDIRS := $(QT_HOME)/shared/pkgs/icv_qt_comp_inhouse.$(VCO)/include

# Link
QT_LIBDIR   := -L$(QT_HOME)/pkgs/icv_lib.$(VCO)/lib64
else
# Qt install dir
QT_HOME := /wv/calibre_3rdparty/QT/qt-5.6.0/$(VCO)

# Qt binaries
QT_BIN := $(QT_HOME)/bin

# Compile
QT_INCDIRS := $(QT_HOME)/include

# Link
QT_LIBDIR   := -L$(QT_HOME)/lib
endif

# Meta-Object Compiler
MOC = $(QT_BIN)/moc
# Resource compiler
RCC = $(QT_BIN)/rcc
# User Interface Compiler
UIC = $(QT_BIN)/uic

# Compile
QT_INCLUDES := -isystem$(QT_INCDIRS)

# Link
QT_CORE_LIB := -lQtCore -lQtXml
QT_GUI_LIB  := -lQtGui $(QT_CORE_LIB)
QT_NETWORK_LIB := -lQtNetwork $(QT_GUI_LIB)
QT_TEST_LIB  := -lQtTest $(QT_GUI_LIB)
