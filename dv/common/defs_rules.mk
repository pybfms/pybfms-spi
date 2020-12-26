
COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SPIBFMS_DIR := $(abspath $(COMMON_DIR)/../..)
PACKAGES_DIR := $(SPIBFMS_DIR)/packages
MKDV_MKFILES_DIR := $(PACKAGES_DIR)/pymkdv/mkfiles

ifneq (1,$(RULES))

PATH := $(PACKAGES_DIR)/python/bin:$(PATH)
export PATH

PYTHONPATH := $(COMMON_DIR)/python:$(SPIBFMS_DIR)/src:$(PYTHONPATH)
export PYTHONPATH

include $(MKDV_MKFILES_DIR)/dv.mk

else # Rules

include $(MKDV_MKFILES_DIR)/dv.mk
endif


