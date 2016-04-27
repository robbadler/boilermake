# boilermake: A reusable, but flexible, boilerplate Makefile.
#
# Copyright 2008, 2009, 2010 Dan Moulding, Alan T. DeKok
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Caution: Don't edit this Makefile! Create your own main.mk and other
#          submakefiles, which will be included by this Makefile.
#          Only edit this if you need to modify boilermake's behavior (fix
#          bugs, add features, etc).

# Note: Parameterized "functions" in this makefile that are marked with
#       "USE WITH EVAL" are only useful in conjuction with eval. This is
#       because those functions result in a block of Makefile syntax that must
#       be evaluated after expansion. Since they must be used with eval, most
#       instances of "$" within them need to be escaped with a second "$" to
#       accomodate the double expansion that occurs when eval is invoked.

# ADD_CLEAN_RULE - Parameterized "function" that adds a new rule and phony
#   target for cleaning the specified target (removing its build-generated
#   files).
#
#   USE WITH EVAL
#
define ADD_CLEAN_RULE
clean: clean_${1}
.PHONY: clean_${1}
clean_${1}:
	$$(strip rm -f \
	  ${${1}_TGTDIR}/${1} \
	  ${${1}_EXPORTDIR}/${1} \
	  ${${1}_TGTDIR}/{*_info,*.py,*.pyc,*.tcl} \
	  $${${1}_OBJS:%.o=%.[doP]})
	$${${1}_POSTCLEAN}
endef

# ADD_OBJECT_RULE - Parameterized "function" that adds a pattern rule for
#   building object files from source files with the filename extension
#   specified in the second argument. The first argument must be the name of the
#   base directory where the object files should reside (such that the portion
#   of the path after the base directory will match the path to corresponding
#   source files). The third argument must contain the rules used to compile the
#   source files into object code form.
#
#   USE WITH EVAL
#
define ADD_OBJECT_RULE
${1}/%.o: ${2}
	$(Q)${3}
endef
#$(eval $(info 1=${1} 2=${2}))
define ADD_OBJECT_RULE2
${1}/%.o: ${2}
	$(Q)${3}
#$(wildcard ${ROOT}/*${VCO})/%.o : $(join $(wildcard ${ROOT}/*src)/,${2})
#	$(Q)${3}
endef

# ADD_MOC_RULE - Parameterized "function" that adds a pattern rule for
#   generating cpp files from QOBJECT class headers. The 2nd argument is the header
#   used to generate the file. The third argument contains the MOC rule macro
#
#   USE WITH EVAL
#
define ADD_MOC_RULE
moc_%.cpp: ${2}
	$(Q)${3}
endef

# SPECIFIC_MOC_RULE - Parameterized "function" that adds a specific rule for
#   generating cpp files from QOBJECT class headers. The 2nd argument is the header
#   used to generate the file. The third argument contains the MOC rule macro
#
#   USE WITH EVAL
#
define SPECIFIC_MOC_RULE
%moc_$(basename $(notdir ${2})).cpp: ${2}
	$(Q)${3}
endef

# ADD_LEX_RULE
#
#   ADD_LEX_RULE <tgt> <lex_src>.l <cmd>
#   USE WITH EVAL
#
define ADD_LEX_RULE
%_l.cxx: ${2}
	$(Q)${3}

clean_${1} : clean_$(strip ${1})_$(strip ${2})
clean_$(strip ${1})_$(strip ${2}) :
	rm -f $(addsuffix *_l.cxx,$(addsuffix /,${${1}_SRCDIRS}))
endef

# ADD_YACC_DEPEND - Parameterized "function" that sets up the dependency on a
#   YACC (bison) generated file. They may be cleaned up correctly, and only
#   generated once instead of repeatedly for each dep file change.
#
#   ADD_YACC_DEPEND <src>.o <yacc_gen>.o <yacc_gen>_p.h <yacc_gen>_p.cxx <TGT>
#   USE WITH EVAL
#
#$(eval $(info 1=${1} 2=${2} 3=${3} 4=${4}))
#$(strip ${1}): $(subst .y,_p.o,$(wildcard $(dir ${1})*.y))
define ADD_YACC_DEPEND
$(strip ${1}): | $(strip ${2}) $(strip ${3}) $(strip ${4})
$(strip ${2}): $(strip ${3})

clean_$(strip ${5}): clean_$(strip ${1})_$(strip ${3})_$(strip ${4})
.PHONY: clean_$(strip ${1})_$(strip ${3})_$(strip ${4})
clean_$(strip ${1})_$(strip ${3})_$(strip ${4}):
	rm -f ${3} ${4} $(addprefix $(dir ${4}),location.hh position.hh stack.hh)
endef

# ADD_YACC_RULE - Parameterized "function" for generating cpp files from YACC inputs.
#   Dependencies are set so that YACC is not called for for both the header and the
#   source files. The first argument is the YACC file. The second argument is the
#   YACC macro.
#
#   USE WITH EVAL
#
define ADD_YACC_RULE
%_p.cxx %_p.h:${1}
	$(Q)${2}
%_p.h:%_p.cxx
%.o:%_p.h
endef

# ADD_SWIG_PYTHON_RULE - Parameterized "function" for pattern rules to generate cpp files
#   from SWIG inputs. The second argument is the SWIG .i file. The third argument is
#   the target directory. Argument four is the SWIG macro.
#
#   USE WITH EVAL
#
define ADD_SWIG_PYTHON_RULE
$(addprefix ${1}/,%_pywrap.cxx) $(addprefix ${3}/,%.py): $(addprefix ${1}/,${2})
	$(Q)${4}
$(addprefix ${3}/,%.py) : $(addprefix ${1}/,%_pywrap.cxx)

$(addprefix ${1}/,%_wrap.cxx) $(addprefix ${3}/,%.py): $(addprefix ${1}/,${2})
	$(Q)${4}
$(addprefix ${3}/,%.py) : $(addprefix ${1}/,%_wrap.cxx)
endef

# ADD_SWIG_TCL_RULE - Parameterized "function" for pattern rules to generate cpp files
#   from SWIG inputs. The second argument is the SWIG .i file. The third argument is
#   the target directory. Argument four is the SWIG macro.
#
#   USE WITH EVAL
#
define ADD_SWIG_TCL_RULE
$(addprefix ${1}/,%_tclwrap.cxx) $(addprefix ${3}/,%.tcl): $(addprefix ${1}/,${2})
	$(Q)${4}
$(addprefix ${3}/,%.tcl) : $(addprefix ${1}/,%_tclwrap.cxx)
endef

# ADD_DEP - Parameterized "function" do add a generic "this before that" step
#
#   USE WITH EVAL
#
define ADD_DEP
${1}: ${2}
endef

# ADD_RESOURCE_RULE - Parameterized "function" do add a pattern rule for QT
#   resource files (images and such). The 2nd argument is the input set, the 3rd
#   argument is the qt rule for packaging resources
define ADD_RESOURCE_RULE
qrc_%.cxx: ${2}
	$(Q)${3}
endef

# EXPORT_FILE - Parameterized "function" to put a target into a specified location
#   EXPORT_FILE <FILE> <TGT_FILE_LOCATION> <EXPORT_DIR>
#
#   USE WITH EVAL
#
#$(eval $(info 1=[${1}] 2=[${2}] 3=[${3}]))
#all: ${3}
define EXPORT_FILE
${3}: ${2}
	@mkdir -p $(strip $(dir ${3}))
	cp ${2} ${3}

clean_${1}: clean_${3}
.PHONY: clean_${3}
clean_${3}:
	rm -f ${3}
endef

define ADD_QPLUGIN_INFO_RULE
${1}: ${${1}_TGTDIR}/$(notdir ${2})
${${1}_TGTDIR}/$(notdir ${2}):
	ln -sf ${2} ${${1}_TGTDIR}
endef

# ADD_TARGET_RULE - Parameterized "function" that adds a new target to the
#   Makefile. The target may be an executable or a library. The two allowable
#   types of targets are distinguished based on the name: library targets must
#   end with the traditional ".a" extension.
#
#   USE WITH EVAL
#
define ADD_TARGET_RULE
    ifeq "$$(suffix ${1})" ".a"
        # Add a target for creating a static library.
        $${${1}_TGTDIR}/${1}: $${${1}_OBJS}
        ##$${TARGET_DIR}/${1}: $${${1}_OBJS}
	     @echo ar $$(notdir $$@)...
	     @mkdir -p $$(dir $$@)
	     $(Q)$$(strip $${AR} $${ARFLAGS} $$@ $${${1}_OBJS})
	     $${${1}_POSTMAKE}
    else ifeq "$$(suffix ${1})" ".sh"
        # Add a target as a stub so that the rule in the submakefile
        # will be properly recognized. Without this stub, the rule
        # in the submakefile will never get called.
        .PHONY:$${${1}_TGTDIR}/${1}_mkdir
        $${${1}_TGTDIR}/${1}: $$(foreach PRE,$${${1}_PREREQS},$$(addprefix $${$${PRE}_EXPORTDIR}/,$${PRE})) $${${1}_TGTDIR}/${1}_mkdir
        $${${1}_TGTDIR}/${1}_mkdir:
	     @mkdir -p $$(dir $$@)
    else
        # Add a target for linking an executable. First, attempt to select the
        # appropriate front-end to use for linking. This might not choose the
        # right one (e.g. if linking with a C++ static library, but all other
        # sources are C sources), so the user makefile is allowed to specify a
        # linker to be used for each target.
        ifeq "$$(strip $${${1}_LINKER})" ""
            # No linker was explicitly specified to be used for this target. If
            # there are any C++ sources for this target, use the C++ compiler.
            # For all other targets, default to using the C compiler.
#            ifneq "$$(strip $$(filter $${CXX_SRC_EXTS},$${${1}_SOURCES}))" ""
                ${1}_LINKER = $${CXX}
#            else
#                ${1}_LINKER = $${CC}
#            endif
        endif

# RE-ENABLE IF WE REMOVE THE .PHONY TARGET MAPPING
        $${${1}_TGTDIR}/${1}: $${${1}_OBJS} $$(foreach PRE,$${${1}_PREREQS},$$(addprefix $${$${PRE}_EXPORTDIR}/,$${PRE}))
#        $${${1}_TGTDIR}/${1}: $${${1}_OBJS} $$(foreach PRE,$${${1}_PREREQS},$$(addprefix $${$${PRE}_TGTDIR}/,$${PRE}))
# END RE-ENABLE
#        $${${1}_TGTDIR}/${1}: $${${1}_OBJS} $${${1}_PREREQS}
	     @mkdir -p $$(dir $$@)
	     @echo $${${1}_LINKER} $$(notdir $$@)...
#	     $$(strip $${${1}_LINKER} -o $$@ $${LDFLAGS} $${${1}_LDFLAGS} \
#	        --whole-archive $${${1}_OBJS} --no-whole-archive $${LDLIBS} $${${1}_LDLIBS})
	     $(Q)$$(strip $${${1}_LINKER} -o $$@ \
	        $${LDFLAGS} $${CXXFLAGS} $${${1}_LDFLAGS} \
	        -Wl,--whole-archive \
	        $${${1}_OBJS} $${${1}_STATICLIBS} \
	        -Wl,--no-whole-archive \
	        $${LDLIBS} $${${1}_LDLIBS})
#		-Wl,--as-needed
	     $${${1}_POSTMAKE}
    endif
endef

# CANONICAL_PATH - Given one or more paths, converts the paths to the canonical
#   form. The canonical form is the path, relative to the project's top-level
#   directory (the directory from which "make" is run), and without
#   any "./" or "../" sequences. For paths that are not  located below the
#   top-level directory, the canonical form is the absolute path (i.e. from
#   the root of the filesystem) also without "./" or "../" sequences.
define CANONICAL_PATH
$(patsubst ${CURDIR}/%,%,$(abspath ${1}))
endef

# COMPILE_C_CMDS - Commands for compiling C source code.
define COMPILE_C_CMDS
	@echo $(strip ${CC}) $(notdir $@)...
	$(Q)mkdir -p $(dir $@)
	$(Q)$(strip ${CC} -o $@ -c -MMD -MF $(addsuffix .d,$(basename $@)) ${CFLAGS} ${SRC_CFLAGS} ${SRC_INCDIRS} ${SYSTEM_INCDIRS} \
	     ${SRC_DEFS} ${DEFS} $<)
	$(Q)cp ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}; \
	$(Q)sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	    -e '/^$$/ d' -e 's/$$/ :/' < ${@:%$(suffix $@)=%.d} \
	    >> ${@:%$(suffix $@)=%.P}; \
	 rm -f ${@:%$(suffix $@)=%.d}
endef

# COMPILE_CXX_CMDS - Commands for compiling C++ source code.
define COMPILE_CXX_CMDS
	@echo $(strip ${CXX}) $(notdir $@)...
	$(Q)mkdir -p $(dir $@)
	$(strip ${PREFIX_CMD} ${CXX} -o $@ -c -MMD -MF $(addsuffix .d,$(basename $@)) -MT '$@' ${CXXFLAGS} ${SRC_CXXFLAGS} ${SRC_INCDIRS} ${SYSTEM_INCDIRS} \
	    ${SRC_DEFS} ${DEFS} $<)
	$(Q)cp ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	    -e '/^$$/ d' -e 's/$$/ :/' < ${@:%$(suffix $@)=%.d} \
	    >> ${@:%$(suffix $@)=%.P}; \
	rm -f ${@:%$(suffix $@)=%.d}
	$(Q)$(if $(findstring moc_,$(strip $@)),\
		sed -e 's#\S*moc_\S*\.cpp.*#\\#' -e 's#^\\##' < ${@:%$(suffix $@)=%.P} >> ${@:%$(suffix $@)=%.d};\
		mv ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}\
	)
	$(Q)$(if $(findstring _wrap,$(strip $@)),\
		sed -e 's#_wrap\.cxx#\.i#' -e 's#^\\##' < ${@:%$(suffix $@)=%.P} >> ${@:%$(suffix $@)=%.d};\
		mv ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}\
	)
	$(Q)$(if $(findstring _pywrap,$(strip $@)),\
		sed -e 's#_pywrap\.cxx#\.i#' -e 's#^\\##' < ${@:%$(suffix $@)=%.P} >> ${@:%$(suffix $@)=%.d};\
		mv ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}\
	)
	$(Q)$(if $(findstring _tclwrap,$(strip $@)),\
		sed -e 's#_tclwrap\.cxx#\.i#' -e 's#^\\##' < ${@:%$(suffix $@)=%.P} >> ${@:%$(suffix $@)=%.d};\
		mv ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}\
	)
	$(Q)$(if $(findstring _l.,$(strip $@)),\
		sed -e 's#_l\.cxx#\.l#' -e 's#^\\##' < ${@:%$(suffix $@)=%.P} >> ${@:%$(suffix $@)=%.d};\
		mv ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}\
	)
#	$(Q)#$(if $(findstring _p,$(strip $@)),\
#		sed -e 's#.*_p\.cxx##' -e 's#.*_p\.h##' -e '/^[[:space:]]\\/ d' -e '/^[[:space:]]:/ d' < ${@:%$(suffix $@)=%.P} >> ${@:%$(suffix $@)=%.d};\
#		mv ${@:%$(suffix $@)=%.d} ${@:%$(suffix $@)=%.P}\
#	)
endef

# GENERATE_MOC_CMDS - Command for calling Qt moc on inputs to create C++ code
define GENERATE_MOC_CMDS
	@echo moc $@...
	$(Q)$(strip ${DISTCC_BIN} ${MOC} -nw ${MOC_FLAGS} -o $@ ${SRC_INCDIRS} ${INCDIRS} $<)
endef

# GENERATE_LEX_CMDS - Command for calling lex to generate C++ code
define GENERATE_LEX_CMDS
	@echo lex $@...
	$(Q)$(strip ${LEX} -Ca -o $@ $<)
endef

# GENERATE_YACC_CMDS - Command for calling yacc to generate C++ code
define GENERATE_YACC_CMDS
	@echo yacc $@...
	$(Q)$(strip ${YACC} ${YACC_FLAGS} --defines=$(call CANONICAL_PATH,$(dir $@)/$(subst .y,_p.h,$(notdir $<))) -o ${@:.h=.cxx}  $<)
endef

# GENERATE_SWIG_PYTHON_CMDS - Commands for calling SWIG to generate C++ and Python and Tcl.
#$(Q)$(strip ${SWIG}  -c++ -python -o $(subst /$(VCO)/,/src/,${@:.py=${PYEXT}}) -outdir ${TGTDIR} ${SRC_INCDIRS} ${INCDIRS} ${SWIG_PYTHON_FLAGS} $<);
define GENERATE_SWIG_PYTHON_CMDS
	@echo SWIG $@...
	$(Q)mkdir -p $(dir $@)
	$(Q)mkdir -p ${TGTDIR}
	$(Q)$(strip ${SWIG}  -c++ -python -o ${@} -outdir ${TGTDIR} ${SRC_INCDIRS} ${INCDIRS} ${SWIG_PYTHON_FLAGS} $<);
endef

# GENERATE_SWIG_TCL_CMDS - Commands for calling SWIG to generate C++ and Tcl and Tcl.
define GENERATE_SWIG_TCL_CMDS
	@echo SWIG $@...
	$(Q)mkdir -p $(dir $@)
	$(Q)mkdir -p ${TGTDIR}
	$(Q)$(strip ${SWIG}  -c++ -tcl -o ${@} -outdir ${TGTDIR} ${SRC_INCDIRS} ${INCDIRS} ${SWIG_TCL_FLAGS} $<);
endef

# GENERATE_RCC_CMDS - Commands for packaging Qt resource files
define GENERATE_RCC_CMDS
	@echo rcc $@
	$(Q)$(strip ${RCC} -name $(notdir $*) -o $@ $<)
endef

# INCLUDE_SUBMAKEFILE - Parameterized "function" that includes a new
#   "submakefile" fragment into the overall Makefile. It also recursively
#   includes all submakefiles of the specified submakefile fragment.
#
#   USE WITH EVAL
#
define INCLUDE_SUBMAKEFILE
    # Initialize all variables that can be defined by a makefile fragment, then
    # include the specified makefile fragment.
    TARGET        :=
    TARGET_DIR    :=
    TGT_CFLAGS    :=
    TGT_CXXFLAGS  :=
    TGT_DEFS      :=
    TGT_INCDIRS   :=
    TGT_LDFLAGS   :=
    TGT_LDLIBS    :=
    TGT_LINKER    :=
    TGT_POSTCLEAN :=
    TGT_POSTMAKE  :=
    TGT_PREREQS   :=
    TGT_CHECK_LIB_DEFS := true

    SOURCES       :=
    SRC_MOC_H     :=
    SRC_CFLAGS    :=
    SRC_CXXFLAGS  :=
    SRC_DEFS      :=
    SRC_INCDIRS   :=
    SRC_NEEDS_MOC :=
    SRC_DEPENDS_ON_YACC :=
    SRC_SWIG_PYTHON_FLAGS := -keyword -builtin
    SRC_SWIG_TCL_FLAGS := -namespace
    SRC_MOC_FLAGS :=
    SRC_VPATH     :=
    UI_NAMES      :=
    BUILD_FIRST   :=
    YACC_FLAGS    :=

    TGT_PLUG_INFO :=
    EXPORT_DIR    :=

    SUBMAKEFILES  :=

    # A directory stack is maintained so that the correct paths are used as we
    # recursively include all submakefiles. Get the makefile's directory and
    # push it onto the stack.
    DIR := $(call CANONICAL_PATH,$(dir ${1}))
    DIR_STACK := $$(call PUSH,$${DIR_STACK},$${DIR})

    include ${1}

    # Initialize internal local variables.
    OBJS :=

    # Ensure that valid values are set for BUILD_DIR and TARGET_DIR.
    ifeq "$$(strip $${BUILD_DIR})" ""
        BUILD_DIR := build
#        BUILD_DIR := $$(addprefix ${CWD}/,$${BUILD_DIR})
#        BUILD_DIR := $$(call CANONICAL_PATH,$${BUILD_DIR})
    endif

    ifeq "$$(strip $${TARGET_DIR})" ""
        TARGET_DIR := $${TARGET_DIR_BASE}
#        TARGET_DIR := $$(call PEEK,$${TARGET_DIR_STACK})
#        ifeq "$$(strip $${TARGET_DIR})" ""
#            TARGET_DIR := .
#        endif
    else
        TARGET_DIR := $$(call CANONICAL_PATH,$$(addprefix $${TARGET_DIR_BASE}/,$${TARGET_DIR}))
    endif

#	TARGET_DIR := $$(subst src,$$(VCO),$$(DIR))

#    TARGET_DIR_STACK := $$(call PUSH,$${TARGET_DIR_STACK},$${TARGET_DIR})
	 #TARGET_DIR := $$(call PEEK,$${TARGET_DIR_STACK})

    ifneq "$$(strip $${EXPORT_DIR})" ""
        EXPORT_DIR := $$(call CANONICAL_PATH,$$(addprefix $${EXPORT_DIR_BASE}/,$${EXPORT_DIR}))
    else
        EXPORT_DIR := $${TARGET_DIR}
#        $$(call CANONICAL_PATH,$${EXPORT_DIR_BASE})
    endif

    # Determine which target this makefile's variables apply to. A stack is
    # used to keep track of which target is the "current" target as we
    # recursively include other submakefiles.
    ifneq "$$(strip $${TARGET})" ""
        # This makefile defined a new target. Target variables defined by this
        # makefile apply to this new target. Initialize the target's variables.
        TGT := $$(strip $${TARGET})
        ALL_TGTS += $${TGT}
        $${TGT}_CFLAGS    := $${TGT_CFLAGS}
        $${TGT}_CXXFLAGS  := $${TGT_CXXFLAGS}
        $${TGT}_DEFS      := $${TGT_DEFS}
        $${TGT}_DEPS      :=
        $${TGT}_SRCDIRS   :=
        TGT_INCDIRS       := $${DIR} $${TGT_INCDIRS}
        TGT_INCDIRS       := $$(call QUALIFY_PATH,$${DIR},$${TGT_INCDIRS})
        TGT_INCDIRS       := $$(call CANONICAL_PATH,$${TGT_INCDIRS})
        $${TGT}_INCDIRS   := $${TGT_INCDIRS}
        $${TGT}_LDFLAGS   :=
            ## RCDH
            ifeq "$$(suffix $${TGT})" ".so"
                $${TGT}_LDFLAGS += -shared
            endif
            ifneq "$$(suffix $${TGT})" ".a"
                ifeq "$$(strip $${TGT_CHECK_LIB_DEFS})" "true"
                    $${TGT}_LDFLAGS += -Wl,--no-undefined
                endif
            endif
        $${TGT}_LDFLAGS   += $${TGT_LDFLAGS}
        $${TGT}_STATICLIBS := $$(filter %.a,$${TGT_LDLIBS})
        $${TGT}_LDLIBS    := $$(filter-out %.a,$${TGT_LDLIBS})
        $${TGT}_LINKER    := $${TGT_LINKER}
        $${TGT}_OBJS      :=
        $${TGT}_POSTCLEAN := $${TGT_POSTCLEAN}
        $${TGT}_POSTMAKE  := $${TGT_POSTMAKE}
        $${TGT}_SOURCES   :=
        $${TGT}_NEEDS_MOC :=
        $${TGT}_TGTDIR    := $${TARGET_DIR}
        $${TGT}_PREREQS   :=
#        ifneq "$$(strip $${TGT_PREREQS})" ""
#          $$(call $$(foreach PRE,$${TGT_PREREQS},\
#                                                    $$(eval $$(info $${TARGET} PRE is [$${PRE}]));\
#                                                    $$(eval $$(info $${PRE}_TGTDIR is [$${$${PRE}_TGTDIR}]));\
#                                                    $$(eval $$(info $${TGT}_PREREQS is [$${$${TGT}_PREREQS}]));\
#                                                    $${TGT}_PREREQS += $${PRE}))
#        endif
        #$${TGT}_PREREQS   := $$(addprefix $${TARGET_DIR}/,$${TGT_PREREQS})
        $${TGT}_PREREQS   := $${TGT_PREREQS}
        $${TGT}_PLUG_INFO :=
        $${TGT}_SWIG_PYTHON_FLAGS := $${SRC_SWIG_PYTHON_FLAGS}
        $${TGT}_SWIG_TCL_FLAGS := $${SRC_SWIG_TCL_FLAGS}
        $${TGT}_MOC_FLAGS := $${SRC_MOC_FLAGS}
        $${TGT}_EXPORTDIR := $${EXPORT_DIR}
    else
        # The values defined by this makefile apply to the the "current" target
        # as determined by which target is at the top of the stack.
        TGT := $$(strip $$(call PEEK,$${TGT_STACK}))
        $${TGT}_CFLAGS    += $${TGT_CFLAGS}
        $${TGT}_CXXFLAGS  += $${TGT_CXXFLAGS}
        $${TGT}_DEFS      += $${TGT_DEFS}
        TGT_INCDIRS       := $${DIR} $${TGT_INCDIRS}
        TGT_INCDIRS       := $$(call QUALIFY_PATH,$${DIR},$${TGT_INCDIRS})
        TGT_INCDIRS       := $$(call CANONICAL_PATH,$${TGT_INCDIRS})
        $${TGT}_INCDIRS   += $${TGT_INCDIRS}
        $${TGT}_LDFLAGS   += $${TGT_LDFLAGS}
        $${TGT}_STATICLIBS += $$(filter %.a,$${TGT_LDLIBS})
        $${TGT}_LDLIBS    += $$(filter-out %.a,$${TGT_LDLIBS})
        $${TGT}_POSTCLEAN += $${TGT_POSTCLEAN}
        $${TGT}_POSTMAKE  += $${TGT_POSTMAKE}
#        $${TGT}_TGTDIR    := $${TARGET_DIR}
#        ifneq "$${TGT_PREREQS}" ""
#          $$(call $$(foreach PRE,$${TGT_PREREQS},$${TGT}_PREREQS += $${PRE}))
#        endif
        #$${TGT}_PREREQS   += $$(addprefix $${TARGET_DIR}/,$${TGT_PREREQS})
        $${TGT}_PREREQS   += $${TGT_PREREQS}
        $${TGT}_SWIG_PYTHON_FLAGS := $${SRC_SWIG_PYTHON_FLAGS}
        $${TGT}_SWIG_TCL_FLAGS := $${SRC_SWIG_TCL_FLAGS}
        $${TGT}_MOC_FLAGS := $${SRC_MOC_FLAGS}
    endif

    ifneq "$$(strip $${TGT_PLUG_INFO})" ""
        TGT_PLUG_INFO     := $$(call QUALIFY_PATH,$${DIR},$${TGT_PLUG_INFO})
        TGT_PLUG_INFO     := $$(call CANONICAL_PATH,$${TGT_PLUG_INFO})
        $${TGT}_PLUG_INFO := $$(strip $${TGT_PLUG_INFO} $${$${TGT}_PLUG_INFO})
    endif

    # Push the current target onto the target stack.
    TGT_STACK := $$(call PUSH,$${TGT_STACK},$${TGT})

    ifneq "$$(strip $${SOURCES})" ""
        # This makefile builds one or more objects from source. Validate the
        # specified sources against the supported source file types.
        BAD_SRCS := $$(strip $$(filter-out $${ALL_SRC_EXTS},$${SOURCES}))
        ifneq "$${BAD_SRCS}" ""
            $$(error Unsupported source file(s) found in ${1} [$${BAD_SRCS}])
        endif

        # Qualify and canonicalize paths.
        ifneq "$$(strip $${SRC_MOC_H})" ""
            SOURCES += $$(patsubst %.h,moc_$${MOC_SRC_EXT},$${SRC_MOC_H})
        endif
        SOURCES     := $$(call QUALIFY_PATH,$${DIR},$${SOURCES})
        SOURCES     := $$(call CANONICAL_PATH,$${SOURCES})
        SRC_INCDIRS := $$(call QUALIFY_PATH,$${DIR},$${SRC_INCDIRS})
        SRC_INCDIRS := $$(call CANONICAL_PATH,$${SRC_INCDIRS})

        # Save the list of source files for this target.
        $${TGT}_SOURCES += $${SOURCES}
        $${TGT}_SRCDIRS += $$(call CANONICAL_PATH,$${DIR})

        # Convert the source file names to their corresponding object file
        # names.
        #OBJS := $$(addprefix $${BUILD_DIR},$$(subst $${ROOT},,$$(addsuffix .o,$${basename $${SOURCES}})))
        #OBJS := $$(subst /src/,/${VCO}/,$$(addsuffix .o,$$(basename $${SOURCES})))
        OBJS := $$(addprefix $$(addsuffix /$${BUILD_DIR}/,$$(DIR)),$$(addsuffix .o,$$(basename $$(notdir $${SOURCES}))))

        # Add the objects to the current target's list of objects, and create
        # target-specific variables for the objects based on any source
        # variables that were defined.
        $${TGT}_OBJS += $${OBJS}
        $${TGT}_DEPS += $${OBJS:%.o=%.P}
        $${OBJS}: SRC_CFLAGS   := $${$${TGT}_CFLAGS} $${SRC_CFLAGS}
        $${OBJS}: SRC_CXXFLAGS := $${$${TGT}_CXXFLAGS} $${SRC_CXXFLAGS}
        $${OBJS}: SRC_DEFS     := $$(addprefix -D,$${$${TGT}_DEFS} $${SRC_DEFS})
        $${OBJS}: SRC_INCDIRS  := $$(addprefix -I,$$(filter-out -I%,$${$${TGT}_INCDIRS} $${SRC_INCDIRS})) $$(filter -I%,$${$${TGT}_INCDIRS} $${SRC_INCDIRS})
        $${OBJS}: SWIG_PYTHON_FLAGS   := $${$${TGT}_SWIG_PYTHON_FLAGS}
        $${OBJS}: SWIG_TCL_FLAGS   := $${$${TGT}_SWIG_TCL_FLAGS}
        $${OBJS}: MOC_FLAGS    := $${$${TGT}_MOC_FLAGS}
        $${OBJS}: YACC_FLAGS   := $${YACC_FLAGS}
        $${OBJS}: TGTDIR       := $${$${TGT}_TGTDIR}
        ifneq "$$(strip $$(filter %_wrap.cxx,$${SOURCES}))" ""
            PYOUT := $$(addprefix $${$${TGT}_TGTDIR}/,$$(patsubst %_wrap.cxx,%.py,$$(notdir $$(strip $$(filter %_wrap.cxx,$${SOURCES})))))
            $${PYOUT}: PYEXT := _wrap.cxx
            $${PYOUT}: TGTDIR :=  $${$${TGT}_TGTDIR}
            $${PYOUT}: SWIG_PYTHON_FLAGS := $${$${TGT}_SWIG_PYTHON_FLAGS}
            $${PYOUT}: SRC_INCDIRS :=$$(addprefix -I,\
                                     $${$${TGT}_INCDIRS} $${SRC_INCDIRS})
        endif
        ifneq "$$(strip $$(filter %_pywrap.cxx,$${SOURCES}))" ""
            PYOUT := $$(addprefix $${$${TGT}_TGTDIR}/,$$(patsubst %_pywrap.cxx,%.py,$$(notdir $$(strip $$(filter %_pywrap.cxx,$${SOURCES})))))
            $${PYOUT}: PYEXT := _pywrap.cxx
            $${PYOUT}: TGTDIR :=  $${$${TGT}_TGTDIR}
            $${PYOUT}: SWIG_PYTHON_FLAGS := $${$${TGT}_SWIG_PYTHON_FLAGS}
            $${PYOUT}: SRC_INCDIRS :=$$(addprefix -I,\
                                     $${$${TGT}_INCDIRS} $${SRC_INCDIRS})
        endif
        ifneq "$$(strip $$(filter %_tclwrap.cxx,$${SOURCES}))" ""
            TCLOUT := $$(addprefix $${$${TGT}_TGTDIR}/,$$(patsubst %_tclwrap.cxx,%.tcl,$$(notdir $$(strip $$(filter %_tclwrap.cxx,$${SOURCES})))))
            $${TCLOUT}: TCLEXT := _tclwrap.cxx
            $${TCLOUT}: TGTDIR :=  $${$${TGT}_TGTDIR}
            $${TCLOUT}: SWIG_TCL_FLAGS := $${$${TGT}_SWIG_TCL_FLAGS}
            $${TCLOUT}: SRC_INCDIRS :=$$(addprefix -I,\
                                     $${$${TGT}_INCDIRS} $${SRC_INCDIRS})
        endif
    endif

    ifneq "$$(strip $${BUILD_FIRST})" ""
        BUILD_FIRST := $$(call QUALIFY_PATH,$${DIR},$${BUILD_FIRST})
        $${TGT}_BUILD_FIRST := $$(call CANONICAL_PATH,$${BUILD_FIRST})
    endif

    ifneq "$$(strip $${UI_NAMES})" ""
        UI_NAMES     := $$(call QUALIFY_PATH,$${DIR},$${UI_NAMES})
        $${TGT}_UI_NAMES := $$(call CANONICAL_PATH,$${UI_NAMES})
    endif

	 ifneq "$$(strip $${SRC_DEPENDS_ON_YACC})" ""
       $${TGT}_DEPENDS_ON_YACC := $$(strip $$(call QUALIFY_PATH,$${DIR},$${SRC_DEPENDS_ON_YACC})) $$(strip $${$${TGT}_DEPENDS_ON_YACC})
       $$(subst /src/,/$$(VCO)/,$$(addsuffix .o,$$(basename $$(strip $$(call QUALIFY_PATH,$${DIR},$${SRC_DEPENDS_ON_YACC}))))): VPATH := $${SRC_VPATH}
	 endif

	 ifneq "$$(strip $${SRC_NEEDS_MOC})" ""
#		Create a target/src specific variable to moc the headers listed
		$${TGT}_NEEDS_MOC += $$(call CANONICAL_PATH,$$(call QUALIFY_PATH,$${DIR},$${SRC_NEEDS_MOC}))
	 endif

    ifneq "$$(strip $${SUBMAKEFILES})" ""
        # This makefile has submakefiles. Recursively include them.
        $$(foreach MK,$${SUBMAKEFILES},\
           $$(eval $$(call INCLUDE_SUBMAKEFILE,\
                      $$(call CANONICAL_PATH,\
                         $$(call QUALIFY_PATH,$${DIR},$${MK})))))
    endif

    # Reset the "current" target to it's previous value.
    TGT_STACK := $$(call POP,$${TGT_STACK})
    TGT := $$(call PEEK,$${TGT_STACK})

	 # RCDH - multi-target
#    TARGET_DIR_STACK := $$(call POP,$${TARGET_DIR_STACK})

    # Reset the "current" directory to it's previous value.
    DIR_STACK := $$(call POP,$${DIR_STACK})
    DIR := $$(call PEEK,$${DIR_STACK})
endef

# MIN - Parameterized "function" that results in the minimum lexical value of
#   the two values given.
define MIN
$(firstword $(sort ${1} ${2}))
endef

# PEEK - Parameterized "function" that results in the value at the top of the
#   specified colon-delimited stack.
define PEEK
$(lastword $(subst :, ,${1}))
endef

# POP - Parameterized "function" that pops the top value off of the specified
#   colon-delimited stack, and results in the new value of the stack. Note that
#   the popped value cannot be obtained using this function; use peek for that.
define POP
${1:%:$(lastword $(subst :, ,${1}))=%}
endef

# PUSH - Parameterized "function" that pushes a value onto the specified colon-
#   delimited stack, and results in the new value of the stack.
define PUSH
${2:%=${1}:%}
endef

# QUALIFY_PATH - Given a "root" directory and one or more paths, qualifies the
#   paths using the "root" directory (i.e. appends the root directory name to
#   the paths) except for paths that are absolute.
define QUALIFY_PATH
$(addprefix ${1}/,$(filter-out /%,${2})) $(filter /%,${2})
endef

###############################################################################
#
# Start of Makefile Evaluation
#
###############################################################################

# Older versions of GNU Make lack capabilities needed by boilermake.
# With older versions, "make" may simply output "nothing to do", likely leading
# to confusion. To avoid this, check the version of GNU make up-front and
# inform the user if their version of make doesn't meet the minimum required.
MIN_MAKE_VERSION := 3.81
MIN_MAKE_VER_MSG := boilermake requires GNU Make ${MIN_MAKE_VERSION} or greater
ifeq "${MAKE_VERSION}" ""
    $(info GNU Make not detected)
    $(error ${MIN_MAKE_VER_MSG})
endif
ifneq "${MIN_MAKE_VERSION}" "$(call MIN,${MIN_MAKE_VERSION},${MAKE_VERSION})"
    $(info This is GNU Make version ${MAKE_VERSION})
    $(error ${MIN_MAKE_VER_MSG})
endif

# Define the source file extensions that we know how to handle.
C_SRC_EXTS := %.c
MOC_SRC_EXT := %.cpp
CXX_SRC_EXTS := %.cxx %.cc %.c++ ${MOC_SRC_EXT} ${C_SRC_EXTS}
#CXX_SRC_EXTS := %.C %.cc %.cp %.cpp %.CPP %.cxx %.c++
GEN_HDR_EXTS := %.h
LEX_SRC_EXT := %.l
YACC_SRC_EXT := %.y
SWIG_SRC_EXT := %.i
RCC_SRC_EXT := %.qrc
ALL_SRC_EXTS := ${C_SRC_EXTS} ${CXX_SRC_EXTS} ${GEN_HDR_EXTS} \
                ${LEX_SRC_EXT} ${YACC_SRC_EXT} \
					 ${SWIG_SRC_EXT} ${RCC_SRC_EXT}

# Initialize global variables.
ALL_TGTS :=
DEFS :=
DIR_STACK :=
INCDIRS :=
TGT_STACK :=
EXPORT_DIR_BASE :=

# Include the main user-supplied submakefile. This also recursively includes
# all other user-supplied submakefiles.
$(eval $(call INCLUDE_SUBMAKEFILE,main.mk))
$(eval $(info Done reading all SUBMAKEFILES))

$(eval $(info QT_VERSION = $(QT_VERSION)))
$(eval $(info TCL_VERSION = $(TCL_VERSION)))
CURRENT_CONFIGURATION := $(shell ./configuration.sh current QT_VERSION=$(QT_VERSION) TCL_VERSION=$(TCL_VERSION))
$(eval $(info Current configuration = $(CURRENT_CONFIGURATION)))

$(eval $(info Adding rules for all targets from Makefiles))

# Perform post-processing on global variables as needed.
DEFS := $(addprefix -D,${DEFS})
SYSTEM_INCDIRS := $(addprefix -isystem,$(call CANONICAL_PATH,${INCDIRS}))
INCDIRS := $(addprefix -I,$(call CANONICAL_PATH,${INCDIRS}))

# Define the "all" target (which simply builds all user-defined targets) as the
# default goal.
.PHONY: all
#all += $(foreach TGT,${ALL_TGTS}, $(addprefix ${${TGT}_TGTDIR}/,${TGT}))
all: $(foreach TGT,${ALL_TGTS}, $(addprefix ${${TGT}_TGTDIR}/,${TGT}))

# ADDED FOR SHORTHAND OF LIB/TARGET NAMES
.PHONY: ${ALL_TGTS}
$(foreach TGT,${ALL_TGTS},$(eval $(call ADD_DEP,${TGT},$(addprefix ${${TGT}_TGTDIR}/,${TGT}))))

# EXPORT TARGETS TO THEIR EXPORT_DIR PATHS, WHICH ARE RELATIVE TO $EXPORT_DIR_BASE
all: $(foreach TGT,${ALL_TGTS},$(addprefix ${${TGT}_EXPORTDIR}/,${TGT}))
$(foreach TGT,${ALL_TGTS},\
  $(if $(filter-out ${${TGT}_TGTDIR},${${TGT}_EXPORTDIR}),\
    $(eval $(call EXPORT_FILE,${TGT},$(addprefix ${${TGT}_TGTDIR}/,${TGT}),$(addprefix ${${TGT}_EXPORTDIR}/,${TGT})))))

# QtPlugin *_INFO files as targets
all: $(foreach TGT,${ALL_TGTS},\
       $(foreach INFO,${${TGT}_PLUG_INFO},\
         ${${TGT}_EXPORTDIR}/$(notdir ${INFO})))

# Add a new target rule for each user-defined target.
$(foreach TGT,${ALL_TGTS},\
  $(eval $(call ADD_TARGET_RULE,${TGT})))

# Add pattern rule(s) for creating compiled object code from C source.
#$(foreach TGT,${ALL_TGTS},\
  $(foreach DIR,${${TGT}_SRCDIRS},\
    $(foreach EXT,${C_SRC_EXTS},\
      $(eval $(call ADD_OBJECT_RULE2,$(subst /src/,/$(VCO)/,${DIR}),\
             $(addprefix ${DIR}/,${EXT}),$${COMPILE_C_CMDS})))))
$(foreach TGT,${ALL_TGTS},\
  $(foreach EXT,${C_SRC_EXTS},\
    $(foreach DIR,${${TGT}_SRCDIRS},\
      $(eval $(call ADD_OBJECT_RULE,$(addprefix ${DIR},/${BUILD_DIR}),\
           $(addprefix ${DIR}/,$(strip ${EXT})),$${COMPILE_C_CMDS})))))

# Add pattern rule(s) for creating compiled object code from C++ source.
#$(foreach TGT,${ALL_TGTS},\
  $(foreach DIR,${${TGT}_SRCDIRS},\
    $(foreach EXT,${CXX_SRC_EXTS},\
      $(eval $(call ADD_OBJECT_RULE2,$(subst /src/,/$(VCO)/,${DIR}),\
               $(addprefix ${DIR}/,${EXT}),$${COMPILE_CXX_CMDS}))\
    )\
  )\
)
$(foreach TGT,${ALL_TGTS},\
  $(foreach EXT,${CXX_SRC_EXTS},\
    $(foreach DIR,${${TGT}_SRCDIRS},\
      $(eval $(call ADD_OBJECT_RULE,$(addprefix ${DIR},/${BUILD_DIR}),\
             $(addprefix ${DIR}/,$(strip ${EXT})),$${COMPILE_CXX_CMDS})))))


# Add "clean" rules to remove all build-generated files.
.PHONY: clean
$(foreach TGT,${ALL_TGTS},\
  $(eval $(call ADD_CLEAN_RULE,${TGT})))

# Include generated rules that define additional (header) dependencies.
$(foreach TGT,${ALL_TGTS},\
  $(eval -include ${${TGT}_DEPS}))

# Include moc rules
$(foreach TGT,${ALL_TGTS},\
  $(eval $(call ADD_MOC_RULE,${TGT},%.h,$${GENERATE_MOC_CMDS})))

# Include YACC dependencies
$(foreach TGT,${ALL_TGTS},\
  $(foreach SRC,${${TGT}_DEPENDS_ON_YACC},\
    $(eval $(call ADD_YACC_DEPEND,\
                                       $(subst /src/,/$(VCO)/,$(addsuffix .o,$(basename ${SRC}))),\
                                       $(subst /src/,/$(VCO)/,$(addsuffix _p.o,$(basename ${SRC}))),\
                                       $(subst .y,_p.h,$(wildcard $(dir ${SRC})*.y)),\
                                       $(subst .y,_p.cxx,$(wildcard $(dir ${SRC})*.y)),\
                                       $(TGT)\
                                       ))\
  )\
)

# Include YACC sources
$(foreach EXT, ${YACC_SRC_EXT},\
  $(eval $(call ADD_YACC_RULE,$(strip ${EXT}),\
                                  $${GENERATE_YACC_CMDS})))

# Include LEX sources
$(foreach TGT,${ALL_TGTS},\
  $(eval $(call ADD_LEX_RULE,${TGT},\
                             ${LEX_SRC_EXT},\
                             $${GENERATE_LEX_CMDS})))

# Include SWIG sources
$(foreach TGT,${ALL_TGTS},\
  $(foreach SRCDIR,${${TGT}_SRCDIRS},\
  $(if $(and $(wildcard $(addprefix ${SRCDIR}/,*.i)),$(filter $(patsubst _%.so,%,$(notdir ${TGT})),$(basename $(notdir $(wildcard $(addprefix ${SRCDIR}/,*.i)))))),\
    $(eval $(call ADD_SWIG_PYTHON_RULE,$(strip ${SRCDIR}),\
                                  $(strip ${SWIG_SRC_EXT}),\
                                  ${${TGT}_TGTDIR},\
                                  $${GENERATE_SWIG_PYTHON_CMDS}))\
    $(eval $(call ADD_SWIG_TCL_RULE,$(strip ${SRCDIR}),\
                                  $(strip ${SWIG_SRC_EXT}),\
                                  ${${TGT}_TGTDIR},\
                                  $${GENERATE_SWIG_TCL_CMDS}))\
    $(eval $(call EXPORT_FILE,${TGT},$(addprefix ${${TGT}_TGTDIR}/,$(filter $(patsubst _%.so,%,$(notdir ${TGT})),$(basename $(notdir $(wildcard $(addprefix ${SRCDIR}/,*.i))))).py),$(addprefix ${${TGT}_EXPORTDIR}/,$(filter $(patsubst _%.so,%,$(notdir ${TGT})),$(basename $(notdir $(wildcard $(addprefix ${SRCDIR}/,*.i))))).py),$(addprefix ${${TGT}_TGTDIR}/,$(filter $(patsubst _%.so,%,$(notdir ${TGT})),$(basename $(notdir $(wildcard $(addprefix ${SRCDIR}/,*.i))))).tcl),$(addprefix ${${TGT}_EXPORTDIR}/,$(filter $(patsubst _%.so,%,$(notdir ${TGT})),$(basename $(notdir $(wildcard $(addprefix ${SRCDIR}/,*.i))))).tcl)))\
  )\
))

# Include Qt resources
$(foreach TGT,${ALL_TGTS},\
  $(eval $(call ADD_RESOURCE_RULE,${BUILD_DIR}/$(call CANONICAL_PATH,${TGT}),\
                                       ${RCC_SRC_EXT},\
                                       $${GENERATE_RCC_CMDS})))

# Include specific moc dependencies from outside of the source directory
$(foreach TGT,${ALL_TGTS},\
  $(foreach MOCCABLE,${${TGT}_NEEDS_MOC},\
    $(eval $(call SPECIFIC_MOC_RULE,${BUILD_DIR}/$(call CANONICAL_PATH,${TGT}),\
                                         ${MOCCABLE},\
                                         $${GENERATE_MOC_CMDS}))))

# Include rules for exporting PyxisOpen plugin info files
$(foreach TGT,${ALL_TGTS},\
  $(foreach INFO,${${TGT}_PLUG_INFO},\
    $(eval $(call ADD_QPLUGIN_INFO_RULE,${TGT},${INFO}))\
    $(eval $(call EXPORT_FILE,${TGT},$(addprefix ${${TGT}_TGTDIR}/,$(notdir ${INFO})),$(addprefix ${${TGT}_EXPORTDIR}/,$(notdir ${INFO}))))\
))
#    $(eval $(call EXPORT_FILE,${INFO},$(join ${${TGT}_TGTDIR},${INFO}),${${TGT}_EXPORTDIR})) \
#    $(eval $(call EXPORT_FILE,${INFO}))\

##$(eval $(info $$MOCCABLE is [${MOCCABLE}]));\

ui_%.h: %.ui
	$(Q)echo Create UI header $@
	$(Q)$(strip $(UIC) -o $@ $<)

$(foreach TGT,${ALL_TGTS},\
  $(foreach UI,${${TGT}_UI_NAMES},\
    $(eval $(call ADD_DEP,$(addprefix ${BUILD_DIR}/$(call CANONICAL_PATH,${TGT})/$(dir ${UI}),\
                                      $(patsubst %.ui,%.o,$(notdir ${UI}))),\
                          $(dir ${UI})/$(patsubst %.ui,ui_%.h,$(notdir ${UI}))))))
#    $(eval $(info $$TGT is [${TGT}]));\
#    $(eval $(info $$UI is [${UI}]));\
#    $(eval $(info $$H is [$(dir ${UI})/$(patsubst %.ui,ui_%.h,$(notdir ${UI}))]));\
#    $(eval $(info $$BLD-dir is [$(addprefix ${BUILD_DIR}/$(call CANONICAL_PATH,${TGT})/$(dir ${UI}),\
#                                      $(patsubst %.ui,%.o,$(notdir ${UI})))]));

$(eval $(info Done adding rules. Dependency graph starting...))
