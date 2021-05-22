MKDV_MK:=$(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR:=$(dir $(MKDV_MK))
MKDV_TOOL ?= icarus

MKDV_VL_SRCS += $(TEST_DIR)/fwnoc_NxN_tb.sv
MKDV_TIMEOUT ?= 10ms

TOP_MODULE = fwnoc_NxN_tb

SIZE_X ?= 2
SIZE_Y ?= 2

MKDV_VL_DEFINES += SIZE_X=$(SIZE_X) SIZE_Y=$(SIZE_Y)

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
