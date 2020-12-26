TEST_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

TOP_MODULE = initiator_smoke_tb
SRCS += $(TEST_DIR)/spi_initiator_smoke_tb.sv

include $(TEST_DIR)/../../common/defs_rules.mk

#********************************************************************
#* cocotb testbench setup
#********************************************************************

MODULE=pybfms_spi_tests.spi_initiator_smoke
export MODULE

PYBFMS_MODULES += spi_bfms

VLSIM_OPTIONS += -Wno-fatal --autoflush

RULES := 1

all : run-$(SIM)

include $(TEST_DIR)/../../common/defs_rules.mk

