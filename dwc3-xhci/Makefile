INSTALL_DIR := $(INSTALL_DIR)/dwc3-xhci_commands
SCRIPTS := load unload

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -fs ../id $(INSTALL_DIR)/id
	@ln -fs ../rreg $(INSTALL_DIR)/rreg
	@ln -fs ../wreg $(INSTALL_DIR)/wreg
	@ln -fs ../trace $(INSTALL_DIR)/trace
	@ln -fs $(INSTALL_DIR)/../dwc3_commands/regdump $(INSTALL_DIR)/regdump
	@ln -fs ../enable_trace $(INSTALL_DIR)/enable_trace

.PHONY: install
