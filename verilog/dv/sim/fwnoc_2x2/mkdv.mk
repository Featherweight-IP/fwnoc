MKDV_MK:=$(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR:=$(dir $(MKDV_MK))

MKDV_VL_SRCS += $(TEST_DIR)/fwnoc_2x2_tb.sv

TOP_MODULE = fwnoc_2x2_tb

MKDV_PLUGINS += cocotb pybfms
PYBFMS_MODULES += rv_bfms gpio_bfms
VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal

MKDV_COCOTB_MODULE ?= fwnoc_tests.fwnoc.smoke

# Bring in the debug BFM
include $(TEST_DIR)/../../../dbg/defs_rules.mk

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk
