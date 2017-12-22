CC = $(CROSS_COMPILE)gcc

default: build

ifneq ($(prefix),)
INSTALL_DIR := $(abspath $(prefix)/dwc_utils)
uninstall:

else
INSTALL_DIR := $(HOME)/bin/dwc_utils
uninstall:
	@echo Uninstalling from $(INSTALL_DIR)...
	@rm -rf $(HOME)/bin/dwc_utils
endif

DWC_LIB_DIR := $(INSTALL_DIR)/lib

# Set libdir to the absolute path in the installed system where the
# binaries are installed. Normally this is the same as INSTALL_DIR
# however if installing to a rootfs image, then this will be
# different.
ifneq ($(libdir),)
MODULE_DIR := $(libdir)
else
MODULE_DIR := $(INSTALL_DIR)
endif

INSTALL := $(realpath ./scripts/install.pl)
INSTALL := $(INSTALL) $(MODULE_DIR)

export CC INSTALL_DIR DWC_LIB_DIR MODULE_DIR INSTALL

build:
	@$(MAKE) -s -C src

VERSION:
	@scripts/gitversion

version: VERSION
	@cat VERSION

install: build uninstall VERSION
	@$(MAKE) -s -C src install
	@$(MAKE) -s -C scripts install
	@$(MAKE) -s -C typec install
	@$(MAKE) -s -C dwc3 install
	@$(MAKE) -s -C dwc3-xhci install
	@$(MAKE) -s -C dwc2 install
	@$(INSTALL) 0644 $(INSTALL_DIR) VERSION

tarball:
	@git archive --format=tar --prefix=usb-scripts/ HEAD > usb-scripts.tar
	@gzip -f usb-scripts.tar

clean:
	@$(MAKE) -s -C src clean
	@rm -rf .tarball usb-scripts.tar.gz VERSION

.PHONY: default build install clean uninstall VERSION version

print-%: ; @echo $*=$($*)
