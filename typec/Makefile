INSTALL_DIR := $(INSTALL_DIR)/typec_commands
SCRIPTS := load regdump i2c

install:
	@$(INSTALL) 0755 $(INSTALL_DIR) $(SCRIPTS)
	@ln -fs $(LINK_DIR)/rreg $(INSTALL_DIR)/rreg
	@ln -fs $(LINK_DIR)/wreg $(INSTALL_DIR)/wreg
	@ln -fs $(LINK_DIR)/id $(INSTALL_DIR)/id
	@ln -fs $(LINK_DIR)/unload $(INSTALL_DIR)/unload

.PHONY: install
