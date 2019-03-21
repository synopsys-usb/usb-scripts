INSTALL_DIR := $(INSTALL_DIR)/typec_commands
SCRIPTS := load regdump i2c

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -s $(LINK_DIR)/rreg $(INSTALL_DIR)/rreg
	@ln -s $(LINK_DIR)/wreg $(INSTALL_DIR)/wreg
	@ln -s $(LINK_DIR)/id $(INSTALL_DIR)/id
	@ln -s $(LINK_DIR)/unload $(INSTALL_DIR)/unload

.PHONY: install
