MKDV_MK:=$(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= sby

MKDV_VL_SRCS += $(TEST_DIR)/fwnoc_fifo_tb.sv

SBY_DEPTH ?= 64
SBY_OPTIONS += mode=bmc expect=pass,fail

TOP_MODULE ?= fwnoc_fifo_tb

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1


include $(TEST_DIR)/../../common/defs_rules.mk


