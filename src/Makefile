CC		:= $(CROSS_COMPILE)gcc
CFLAGS		:= -Os
OUT_DIR		:= .out
BINARIES	:= initram_4gb initram_2gb initram_64mb rdmem wrmem
BINARIES	:= $(addprefix $(OUT_DIR)/, $(BINARIES))
_MKDIR		:= $(shell mkdir -p $(OUT_DIR))

default: build

install: build
	@$(INSTALL) 0755 $(INSTALL_DIR) $(BINARIES)

$(OUT_DIR)/%: %.c
	@echo CC $<
	@$(CC) $(CFLAGS) -o $@ $<

build: $(BINARIES)

clean:
	@rm -rf $(OUT_DIR)

.PHONY: default install build clean
