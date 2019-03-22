VERSION = 1
PATCHLEVEL = 0
SUBLEVEL = 3

USBSCRIPTS_VERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))

CC = $(CROSS_COMPILE)gcc

default: build

ifneq ($(prefix),)
INSTALL_DIR := $(abspath $(prefix)/dwc_utils)
else
INSTALL_DIR := $(HOME)/bin/dwc_utils
endif

# Set lndir to link location of the lib scripts installed in rootfs.
# For example, lndir=/root/bin/dwc_utils
# This is needed when generating rootfs from buildroot.
ifneq ($(lndir),)
LINK_DIR := $(lndir)
else
LINK_DIR := $(INSTALL_DIR)
endif

INSTALL := $(realpath ./scripts/install.pl)
INSTALL := $(INSTALL) $(LINK_DIR)

export CC INSTALL_DIR LINK_DIR INSTALL

build:
	@$(MAKE) -s -C src

uninstall:
	@echo Uninstalling from $(INSTALL_DIR)...
	@rm -rf $(INSTALL_DIR)

init_version:
	@echo $(USBSCRIPTS_VERSION)-`scripts/gitversion` > VERSION

version: init_version
	@cat VERSION

install: build uninstall init_version
	@$(MAKE) -s -C src install
	@$(MAKE) -s -C scripts install
	@$(MAKE) -s -C typec install
	@$(MAKE) -s -C dwc3 install
	@$(MAKE) -s -C dwc3-xhci install
	@$(MAKE) -s -C dwc2 install
	@$(MAKE) -s -C haps install
	@$(INSTALL) 0644 $(INSTALL_DIR) VERSION

tarball:
	@git archive --format=tar --prefix=usb-scripts/ HEAD > usb-scripts.tar
	@gzip -f usb-scripts.tar

clean:
	@$(MAKE) -s -C src clean
	@rm -rf .tarball usb-scripts.tar.gz VERSION

.PHONY: default build install clean uninstall init_verison version

print-%: ; @echo $*=$($*)
