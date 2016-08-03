TARGET := libanimals$(LIB_EXT)

SOURCES := \
    animal.cc \

TGT_INCDIRS := .

# chihuahua has its own submakefile because it has a specific SRC_DEFS that we
# want to apply only to it
SUBMAKEFILES := \
                dog/chihuahua/chihuahua.mk \
                dog/dog.mk \
                cat/cat.mk \
                mouse/mouse.mk


