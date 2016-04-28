ifneq ($(QT_VERSION), 5)
# Qt install dir
QT_HOME := /wv/ic_wg_server/ic/qt/exports.v0-0_3-10-2015_engr-$(VCO)/mgc_home

# Qt binaries
QT_BIN := $(QT_HOME)/shared/pkgs/icv_qt_comp_inhouse.$(VCO)/bin

# Meta-Object Compiler
MOC = $(QT_BIN)/moc
# Resource compiler
RCC = $(QT_BIN)/rcc
# User Interface Compiler
UIC = $(QT_BIN)/uic

# Compile
QT_INCDIRS := $(QT_HOME)/shared/pkgs/icv_qt_comp_inhouse.$(VCO)/include
QT_INCLUDES := -isystem$(QT_INCDIRS)

# Link
QT_LIBDIR   := -L$(QT_HOME)/pkgs/icv_lib.$(VCO)/lib64
QT_CORE_LIB := -lQtCore -lQtXml
QT_GUI_LIB  := -lQtGui $(QT_CORE_LIB)
QT_NETWORK_LIB := -lQtNetwork $(QT_GUI_LIB)
QT_TEST_LIB  := -lQtTest $(QT_GUI_LIB)
else
# Qt install dir
QT_HOME := /wv/cal_wg_server/ic/qt5/exports.v0-0_4-8-2016_engr-$(VCO)/mgc_home

# Qt binaries
QT_BIN := $(QT_HOME)/shared/pkgs/icv_qt5_comp_inhouse.$(VCO)/bin

# Meta-Object Compiler
MOC = $(QT_BIN)/moc
# Resource compiler
RCC = $(QT_BIN)/rcc
# User Interface Compiler
UIC = $(QT_BIN)/uic

# Compile
QT_INCDIRS := $(QT_HOME)/shared/pkgs/icv_qt5_comp_inhouse.$(VCO)/include
QT_INCLUDES := -isystem$(QT_INCDIRS)

# Link
QT_LIBDIR   := -L$(QT_HOME)/pkgs/icv_lib.$(VCO)/lib64
QT_CORE_LIB := -lQt5Core -lQt5Xml -lQt5Concurrent
QT_GUI_LIB  := -lQt5Widgets -lQt5Gui $(QT_CORE_LIB)
QT_NETWORK_LIB := -lQt5Network $(QT_GUI_LIB)
QT_TEST_LIB  := -lQt5Test $(QT_GUI_LIB)

# Qt plugins
QT_PLUGINS := $(QT_HOME)/pkgs/icv_qt5_comp.$(VCO)/plugins
endif
