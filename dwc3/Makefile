INSTALL_DIR := $(INSTALL_DIR)/dwc3_commands
SCRIPTS := load info wakeup

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -fs ../rreg $(INSTALL_DIR)/rreg
	@ln -fs ../wreg $(INSTALL_DIR)/wreg
	@ln -fs $(DWC_LIB_DIR)/id $(INSTALL_DIR)/id
	@ln -fs $(DWC_LIB_DIR)/unload $(INSTALL_DIR)/unload
	@ln -fs $(DWC_LIB_DIR)/trace $(INSTALL_DIR)/trace
	@ln -fs $(DWC_LIB_DIR)/enable_trace $(INSTALL_DIR)/enable_trace
	@ln -fs $(DWC_LIB_DIR)/regdump $(INSTALL_DIR)/regdump
	@ln -fs $(DWC_LIB_DIR)/audio $(INSTALL_DIR)/audio

.PHONY: install
