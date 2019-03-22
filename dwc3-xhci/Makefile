INSTALL_DIR := $(INSTALL_DIR)/dwc3-xhci_commands
SCRIPTS := load

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -s $(LINK_DIR)/lib/rreg $(INSTALL_DIR)/rreg
	@ln -s $(LINK_DIR)/lib/wreg $(INSTALL_DIR)/wreg
	@ln -s $(LINK_DIR)/lib/id $(INSTALL_DIR)/id
	@ln -s $(LINK_DIR)/lib/unload $(INSTALL_DIR)/unload
	@ln -s $(LINK_DIR)/lib/trace $(INSTALL_DIR)/trace
	@ln -s $(LINK_DIR)/lib/regdump $(INSTALL_DIR)/regdump
	@ln -s $(LINK_DIR)/lib/enable_trace $(INSTALL_DIR)/enable_trace

.PHONY: install
