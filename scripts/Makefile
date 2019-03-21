SH_SCRIPTS := lssnps
PERL_SCRIPTS := initram netconsole rreg wreg decode_stacktrace trb-info repo dx
LIB_SCRIPTS := dwc.pl id trace enable_trace clear_trace regdump unload audio
PERL_MODULES := USBScripts.pm HAPSScripts.pm
OTHER := completions.sh

default:

install_run:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(PERL_SCRIPTS)
	@$(INSTALL) 0755 $(DWC_LIB_DIR) $(LIB_SCRIPTS)

install_other:
	@$(INSTALL) 0644 $(INSTALL_DIR) $(PERL_MODULES) $(OTHER)

make_links:
	@ln -s $(LINK_DIR)/dwc.pl $(INSTALL_DIR)/xhci
	@ln -s $(LINK_DIR)/dwc.pl $(INSTALL_DIR)/dwc3-xhci
	@ln -s $(LINK_DIR)/dwc.pl $(INSTALL_DIR)/dwc3
	@ln -s $(LINK_DIR)/dwc.pl $(INSTALL_DIR)/dwc2
	@ln -s $(LINK_DIR)/dwc.pl $(INSTALL_DIR)/typec
	@ln -s $(LINK_DIR)/dwc.pl $(INSTALL_DIR)/haps
	@ln -s $(LINK_DIR)/audio $(INSTALL_DIR)/audio

install: install_run install_other make_links

.PHONY: default install install_run install_other
