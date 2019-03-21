INSTALL_DIR := $(INSTALL_DIR)/dwc2_commands
SCRIPTS := load params

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -s $(LINK_DIR)/rreg $(INSTALL_DIR)/rreg
	@ln -s $(LINK_DIR)/wreg $(INSTALL_DIR)/wreg
	@ln -s $(LINK_DIR)/id $(INSTALL_DIR)/id
	@ln -s $(LINK_DIR)/unload $(INSTALL_DIR)/unload
	@ln -s $(LINK_DIR)/trace $(INSTALL_DIR)/trace
	@ln -s $(LINK_DIR)/enable_trace $(INSTALL_DIR)/enable_trace
	@ln -s $(LINK_DIR)/regdump $(INSTALL_DIR)/regdump

.PHONY: install
