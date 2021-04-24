
FWNOC_VERILOG_SYNTH_COMMONDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(FWNOC_VERILOG_SYNTH_COMMONDIR)/../../../packages)
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$PATH python3 -m mkdv mkfile)

ifneq (1,$(RULES))

include $(FWNOC_VERILOG_SYNTH_COMMONDIR)/../../rtl/defs_rules.mk
include $(DV_MK)

else # Rules

include $(DV_MK)

endif
