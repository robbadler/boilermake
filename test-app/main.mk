CXXFLAGS := -g -O0 -Wall -pipe

SUBMAKEFILES := talk.mk animals/animals.mk

ROOT := $(abspath .)
CWD := $(addsuffix /,$(shell pwd))
#BUILD_DIR := $(addprefix ${CWD},${BUILD_DIR})
EXPORT_DIR_BASE := ./

