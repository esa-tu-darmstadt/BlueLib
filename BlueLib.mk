MAKEPATH := $(dir $(lastword $(MAKEFILE_LIST)))
MODULENAME := BlueLib
MODULEPATH := $(MAKEPATH)src
EXTRA_BSV_LIBS += $(MODULEPATH)

$(info Adding $(MODULENAME) from $(MODULEPATH))
ifeq ($(wildcard $(MODULEPATH)/BDPI/),)
$(warning ./src/BDPI/ folder not found. BlueLib packages requiring C functions may not link successfully.)
else
C_FILES += $(wildcard $(MODULEPATH)/BDPI/*.c)
endif