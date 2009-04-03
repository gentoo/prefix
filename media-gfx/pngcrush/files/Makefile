GAS_VERSION = $(shell as --version | sed -n -e's/GNU assembler (.*) //p')
CFLAGS += -I. -Wall
CPPFLAGS += -DPNG_USE_PNGGCCRD -DPNG_iCCP_SUPPORTED \
	-DPNG_iTXt_SUPPORTED -DPNG_USE_GLOBAL_ARRAYS \
	-DGAS_VERSION="\"${GAS_VERSION}\""
LDLIBS += -lpng -lz
all: pngcrush
