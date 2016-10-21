INSTALL_DIR	:= $(INSTALL_DIR)

SH_SCRIPTS := lssnps
PERL_SCRIPTS := initram netconsole rreg wreg dwc.pl id trace
PERL_MODULES := USBScripts.pm
OTHER := completions.sh

default:

install_run:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(PERL_SCRIPTS)

install_other:
	@$(INSTALL) 0644 $(INSTALL_DIR) $(PERL_MODULES) $(OTHER)

make_links:
	@ln -fs dwc.pl $(INSTALL_DIR)/dwc3-xhci
	@ln -fs dwc.pl $(INSTALL_DIR)/dwc3
	@ln -fs dwc.pl $(INSTALL_DIR)/dwc2
	@ln -fs rreg $(INSTALL_DIR)/rd
	@ln -fs wreg $(INSTALL_DIR)/wr

install: install_run install_other make_links

.PHONY: default install install_run install_other
