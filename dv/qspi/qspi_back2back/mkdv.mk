#****************************************************************************
#* mkdv.mk
#****************************************************************************
MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(abspath $(dir $(MKDV_MK)))

TOP_MODULE = qspi_back2back_tb
MKDV_TOOL ?= icarus
MKDV_PLUGINS += cocotb pybfms

include $(TEST_DIR)/../../common/defs_rules.mk

MKDV_VL_SRCS += $(TEST_DIR)/qspi_back2back_tb.sv
MKDV_VL_SRCS += $(PACKAGES_DIR)/pymkdv/include/resetgen.sv

VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal


#********************************************************************
#* cocotb testbench setup
#********************************************************************

MODULE=pybfms_spi_tests.qspi_back2back_smoke
export MODULE

PYBFMS_MODULES += spi_bfms

VLSIM_OPTIONS += -Wno-fatal --autoflush

RULES := 1


include $(TEST_DIR)/../../common/defs_rules.mk

