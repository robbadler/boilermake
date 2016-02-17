
QT_INCDIRS  := $(MGC_HOME)/shared/pkgs/qt_inhouse/include
QT_INCLUDES := -isystem$(QT_INCDIRS)
QT_LIBDIR   := -L$(MGC_HOME)/pkgs/qt/lib
QT_CORE_LIB := -lQtCore -lQtTest -lQtXml
QT_GUI_LIB  := -lQtGui -lQtCore -lQtTest -lQtXml
