PETSC_BASE := /project/dsm/cicd/tools/pyxis/petsc-3.3-p7

PETSC_INCDIRS := $(PETSC_BASE)/include

PETSC_LIBDIR := -L$(PETSC_BASE)/lib

PETSC_LIBS := -l:libpetsc.a \
				  -l:libmpich.a \
				  -l:libmpl.a \
				  -lf2clapack \
				  -lf2cblas
