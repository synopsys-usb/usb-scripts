INSTALL_DIR := $(INSTALL_DIR)/typec_commands
SCRIPTS := load regdump i2c

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -fs ../rreg $(INSTALL_DIR)/rreg
	@ln -fs ../wreg $(INSTALL_DIR)/wreg
	@ln -fs $(DWC_LIB_DIR)/id $(INSTALL_DIR)/id
	@ln -fs $(DWC_LIB_DIR)/unload $(INSTALL_DIR)/unload

.PHONY: install
