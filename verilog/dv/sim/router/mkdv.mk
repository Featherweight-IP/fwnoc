MKDV_MK:=$(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR:=$(dir $(MKDV_MK))

MKDV_VL_SRCS += $(TEST_DIR)/fwnoc_router_tb.sv

TOP_MODULE = fwnoc_router_tb

MKDV_PLUGINS += cocotb pybfms
PYBFMS_MODULES += rv_bfms

MKDV_COCOTB_MODULE ?= fwnoc_tests.router.smoke

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk
