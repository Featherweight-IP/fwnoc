
MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))

MKDV_TOOL ?= openlane
TOP_MODULE = fwnoc_2x2

QUARTUS_FAMILY ?= "Cyclone V"
QUARTUS_DEVICE ?= 5CGXFC7C7F23C8
#QUARTUS_FAMILY ?= "Max 10"
#QUARTUS_DEVICE ?= 10M50DAF484C6GES
SDC_FILE=$(SYNTH_DIR)/$(TOP_MODULE).sdc

MKDV_VL_SRCS += $(SYNTH_DIR)/fwnoc_2x2.v

include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

