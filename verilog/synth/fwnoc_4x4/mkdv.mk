
MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))

MKDV_TOOL ?= openlane
TOP_MODULE = fwnoc_2x2

MKDV_VL_SRCS += $(SYNTH_DIR)/fwnoc_2x2.v

include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

