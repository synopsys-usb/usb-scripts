INSTALL_DIR := $(INSTALL_DIR)/typec_commands
SCRIPTS := load regdump i2c

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -s $(LINK_DIR)/lib/rreg $(INSTALL_DIR)/rreg
	@ln -s $(LINK_DIR)/lib/wreg $(INSTALL_DIR)/wreg
	@ln -s $(LINK_DIR)/lib/id $(INSTALL_DIR)/id
	@ln -s $(LINK_DIR)/lib/unload $(INSTALL_DIR)/unload

.PHONY: install
