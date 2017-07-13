INSTALL_DIR := $(INSTALL_DIR)/dwc2_commands
SCRIPTS := load

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -fs ../id $(INSTALL_DIR)/id
	@ln -fs ../rreg $(INSTALL_DIR)/rreg
	@ln -fs ../wreg $(INSTALL_DIR)/wreg
	@ln -fs ../dwc3_commands/unload $(INSTALL_DIR)/unload
	@ln -fs ../trace $(INSTALL_DIR)/trace
	@ln -fs ../enable_trace $(INSTALL_DIR)/enable_trace
.PHONY: install
