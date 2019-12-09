# Intended to be run from inside pytorch source dir

all:

pytorch-install: export PATH=/opt/rh/devtoolset-8/root/usr/bin:$(shell echo $$PATH) # Needs C++14
pytorch-install: export DEBUG=1
pytorch-install: export BLAS=OpenBLAS
pytorch-install: export OpenBLAS_HOME=/mnt/users/ssd1/no_backup/bandhav/tmp/pytorch_test/openblas-install
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
	python setup.py develop

pytorch-uninstall:
	pip uninstall torch
	pip uninstall torch
	python setup.py clean

# BLAS Profiling
profile: export LD_PROFILE_OUTPUT=$(shell pwd)
profile: export LD_PROFILE=libopenblas.so.0
profile:
	@echo $$LD_PROFILE
	rm -f $$LD_PROFILE.profile
	python conv2d_example.py
	sprof ./openblas-install/lib/$$LD_PROFILE $$LD_PROFILE.profile > conv2d_exmaple.profile.log

clean:
	rm *.profile *.log
