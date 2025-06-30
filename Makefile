INSTALL_DIR = $(HOME)/.local/bin

install:
	mkdir -p $(INSTALL_DIR)
	cp consession.sh $(INSTALL_DIR)/consession
	chmod +x $(INSTALL_DIR)/consession

