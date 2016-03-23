

QT_HOME     :=/project/dsm/cicd/icf_wg_server/cicd/qt4/exports.v4-8_6-0-4_engr-$(VCO)/mgc_home/
QT_BINDIR  := $(QT_HOME)/pkgs/qt_inhouse.$(VCO)/bin

MOC := $(QT_BINDIR)/moc
RCC := $(QT_BINDIR)/rcc
UIC := $(QT_BINDIR)/uic

QT_INCDIRS  := $(QT_HOME)/shared/pkgs/qt_inhouse.$(VCO)/include
QT_INCLUDES := -isystem$(QT_INCDIRS)
QT_LIBDIR   := -L$(QT_HOME)/pkgs/qt.$(VCO)/lib

QT_CORE_LIB := -lQtCore -lQtXml
QT_GUI_LIB  := -lQtGui -lQtCore -lQtXml
QT_TEST_LIB := -lQtTest -lQtXml -lQtCore
