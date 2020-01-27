TOPDIR := $(shell git rev-parse --show-toplevel)
OPENBLAS_DIR := $(TOPDIR)/OpenBLAS
PYTORCH_DIR := $(TOPDIR)/pytorch
HOST_TOOLCHAIN := /opt/rh/devtoolset-8/root/usr/bin # Needs C++14
CONDA_PREFIX := $(dir $(abspath $(shell which python)/..))
PROG := $(TOPDIR)/benchmarks/conv2d_example.py

help:

install-all:
	cd $(TOPDIR) && $(MAKE) openblas-install
	cd $(TOPDIR) && $(MAKE) pytorch-install

uninstall-all:
	cd $(TOPDIR) && $(MAKE) openblas-uninstall
	cd $(TOPDIR) && $(MAKE) pytorch-uninstall

openblas-install:
	@echo $(CONDA_PREFIX)
	cd $(OPENBLAS_DIR) && $(MAKE)
	cd $(OPENBLAS_DIR) && $(MAKE) install PREFIX=$(CONDA_PREFIX)

openblas-uninstall:
	cd $(OPENBLAS_DIR) && $(MAKE) clean

pytorch-install: export USE_HB=1
pytorch-install: export HB_HOST_DIR=$(TOPDIR)/../bsg_bladerunner/bsg_f1/libraries
pytorch-install: export HB_DEVICE_DIR=$(TOPDIR)/../bsg_bladerunner/bsg_manycore/software/tensorlib/build
pytorch-install: export PATH=$(strip $(HOST_TOOLCHAIN)):$(shell echo $$PATH)
pytorch-install: export DEBUG=1
pytorch-install: export BLAS=OpenBLAS
pytorch-install: export OpenBLAS_HOME=$(CONDA_PREFIX)
pytorch-install: export USE_DISTRIBUTED=0
pytorch-install: export USE_MKL=0
pytorch-install: export USE_MKLDNN=0
pytorch-install: export USE_CUDA=0
pytorch-install: export BUILD_TEST=0
pytorch-install: export USE_FBGEMM=0
pytorch-install: export USE_NNPACK=0
pytorch-install: export USE_QNNPACK=0
pytorch-install: export USE_OPENMP=0
pytorch-install: export CFLAGS:=$(CFLAGS)
pytorch-install: export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
pytorch-install:
	cd $(PYTORCH_DIR) && python setup.py develop

pytorch-uninstall:
	-cd $(PYTORCH_DIR) && conda uninstall pytorch
	cd $(PYTORCH_DIR) && pip uninstall torch
	cd $(PYTORCH_DIR) && pip uninstall torch
	cd $(PYTORCH_DIR) && python setup.py clean

# BLAS Profiling
blas-profile: export LD_PROFILE=libopenblas.so.0
blas-profile: LD_PROFILE_PATH=$(CONDA_PREFIX)/lib
blas-profile: profile

# TORCH Profiling
torch-profile: export LD_PROFILE=libtorch_python.so
torch-profile: LD_PROFILE_PATH=$(TOPDIR)/pytorch/build/lib
torch-profile: profile

.PHONY: profile
profile: export LD_PROFILE_OUTPUT=$(shell pwd)
profile:
	@echo Profiling $$LD_PROFILE on $(PROG)...
	rm -f $$LD_PROFILE.profile
	python $(PROG)
	sprof $(LD_PROFILE_PATH)/$$LD_PROFILE $$LD_PROFILE.profile

clean:
	rm *.profile *.log
