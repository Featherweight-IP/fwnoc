FWNOC_VERILOG_DV_COMMONDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(FWNOC_VERILOG_DV_COMMONDIR)/../../../packages)
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$PATH python3 -m mkdv mkfile)

ifneq (1,$(RULES))

include $(FWNOC_VERILOG_DV_COMMONDIR)/../../rtl/defs_rules.mk

MKDV_PYTHONPATH += $(FWNOC_VERILOG_DV_COMMONDIR)/python

include $(DV_MK)

else # Rules

include $(DV_MK)

endif
