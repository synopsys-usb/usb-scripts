INSTALL_DIR := $(INSTALL_DIR)/dwc3_commands
SCRIPTS := load unload trace enable_trace regdump info

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -fs ../id $(INSTALL_DIR)/id
	@ln -fs ../rreg $(INSTALL_DIR)/rreg
	@ln -fs ../wreg $(INSTALL_DIR)/wreg

.PHONY: install
