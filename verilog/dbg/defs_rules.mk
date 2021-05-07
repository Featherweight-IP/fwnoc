
FWNOC_VERILOG_DBGDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifneq (1,$(RULES))

ifeq (,$(findstring $(FWNOC_VERILOG_DBGDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(FWNOC_VERILOG_DBGDIR)
MKDV_VL_SRCS += $(wildcard $(FWNOC_VERILOG_DBGDIR)/*.v)
MKDV_VL_DEFINES += FWNOC_ROUTER_DBG_MODULE=fwnoc_router_dbg_bfm

PYBFMS_MODULES += fwnoc_dbg_bfms

MKDV_PYTHONPATH += $(FWNOC_VERILOG_DBGDIR)/python

endif

else # Rules

endif
