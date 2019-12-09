TOPDIR := $(shell git rev-parse --show-toplevel)
OPENBLAS_DIR := $(TOPDIR)/OpenBLAS
PYTORCH_DIR := $(TOPDIR)/pytorch
HOST_TOOLCHAIN := /opt/rh/devtoolset-8/root/usr/bin # Needs C++14

all:

openblas-install:
	cd $(OPENBLAS_DIR) && mkdir -p build
	cd $(OPENBLAS_DIR) && $(MAKE)
	cd $(OPENBLAS_DIR) && $(MAKE) install PREFIX=$(OPENBLAS_DIR)/build

openblas-uninstall:
	cd $(OPENBLAS_DIR) && rm -rf build
	cd $(OPENBLAS_DIR) && $(MAKE) clean

pytorch-install: export PATH=$(HOST_TOOLCHAIN):$(shell echo $$PATH)
pytorch-install: export DEBUG=1
pytorch-install: export BLAS=OpenBLAS
pytorch-install: export OpenBLAS_HOME=$(OPENBLAS_DIR)/build
pytorch-install: export USE_NUMPY=0
pytorch-install: export USE_DISTRIBUTED=0
pytorch-install: export USE_MKLDNN=0
pytorch-install: export USE_CUDA=0
pytorch-install: export BUILD_TEST=0
pytorch-install: export USE_FBGEMM=0
pytorch-install: export USE_NNPACK=0
pytorch-install: export USE_QNNPACK=0
pytorch-install: export USE_OPENMP=0
pytorch-install: export CFLAGS:=$(CFLAGS)
pytorch-install:
	cd $(PYTORCH_DIR) && python setup.py develop

pytorch-uninstall:
	cd $(PYTORCH_DIR) && pip uninstall torch
	cd $(PYTORCH_DIR) && pip uninstall torch
	cd $(PYTORCH_DIR) && python setup.py clean

# BLAS Profiling
profile: export LD_PROFILE_OUTPUT=$(shell pwd)
profile: export LD_PROFILE=libopenblas.so.0
profile:
	@echo $$LD_PROFILE
	rm -f $$LD_PROFILE.profile
	python conv2d_example.py
	sprof $(OPENBLAS_DIR)/build/lib/$$LD_PROFILE $$LD_PROFILE.profile > conv2d_exmaple.profile.log

clean:
	rm *.profile *.log
