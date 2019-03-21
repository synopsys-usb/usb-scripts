INSTALL_DIR := $(INSTALL_DIR)/dwc3-xhci_commands
SCRIPTS := load

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -fs $(LINK_DIR)/rreg $(INSTALL_DIR)/rreg
	@ln -fs $(LINK_DIR)/wreg $(INSTALL_DIR)/wreg
	@ln -fs $(LINK_DIR)/id $(INSTALL_DIR)/id
	@ln -fs $(LINK_DIR)/unload $(INSTALL_DIR)/unload
	@ln -fs $(LINK_DIR)/trace $(INSTALL_DIR)/trace
	@ln -fs $(LINK_DIR)/regdump $(INSTALL_DIR)/regdump
	@ln -fs $(LINK_DIR)/enable_trace $(INSTALL_DIR)/enable_trace

.PHONY: install
