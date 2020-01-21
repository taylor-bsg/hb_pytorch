# HammerBlade backend for PyTorch
Repo to experiment with PyTorch backends

Running PyTorch on HammerBlade cosim:
-------------------------------------
- Get the source:
  ```
  # Clone bsg_bladerunner and hb_pytorch in a common parent directory.
  https://github.com/bespoke-silicon-group/bsg_bladerunner.git
  git clone https://github.com/taylor-bsg/hb_pytorch.git
  git submodule update --init --recursive
  ```
- Setup bsg_bladerunner by running:
  ```
  cd bsg_bladerunner
  make setup
  cd ..
  ```
- Setup Python environment captured in [environment.yml](https://github.com/taylor-bsg/hb_pytorch/blob/master/environment.yml); explained in "Python environment setup" section below.
- Build PyTorch:
  ```
  cd hb_pytorch
  # Make sure to be in 'torchsrc' conda environment see in the step above
  make pytorch-install
  cd ..
  ```
- Run a Python program by invoking interpreter in cosim:
  ```
  cd bsg_bladerunner/bsg_f1/testbenches/python
  make test_python.log
  ```

Python environment setup:
------------------------
PyTorch recommends installation in [Ananconda environments](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html). Even the
PyTorch source build could be confined to an environment allowing us to keep 
the system-wide python version intact. This section lists a set of steps to install
Miniconda (light version of Ananconda package manager), create a Python environment
with packages listed in `environment.yml` file and shows how to activate that
environment.

Installing Miniconda (skip to next sub-section if have this already installed):
```
# Download the installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Install Miniconda
bash Miniconda3-latest-Linux-x86_64.sh
# This prompts to read the licence: 
#   - Press 'Enter', scroll through the licence and accept it
# Then it prompts to enter the install directory: 
#   - Provide desired path (installer would create a dir with this name).
#   - The path above would be CONDA_PREFIX.
# Then it prompts to initialize Miniconda: 
#   - Enter 'yes'. This modifies ~/.bashrc; there doesn't seem to be a workaround for this.

# Run the command below if you don't want conda to be
# activated automatically whenever you open a new terminal.
conda config --set auto_activate_base False

rm Miniconda3-latest-Linux-x86_64.sh
```

Conda env setup:
```
conda update -n base -c defaults conda
conda env create -f environment.yml
conda activate torchsrc
```

PyTorch build:
--------------

Installation targets:
```
# Make sure to be in desired conda enviroment
make openblas-install # Builds the source and installs openblas in conda env
make pytorch-install # Builds the source and installs PyTorch in the conda env

make pytorch-uninstall # Uninstall and clean PyTorch source directory
make openblas-uninstall # Uninstall and clean OpenBLAS source directory

make install-all # Builds and installs OpenBLAS and PyTorch
make uninstall-all # Uninstall and clean OpenBLAS and PyTorch
```

Check PyTorch:
```
python check_pytorch.py # Prints pytorch installation's build config
python benchmarks/cond2d_example.py # Simple conv2d operation to understand the call stack
```

Profiling (using `sprof`):
```
# Profile libopenblas.so on PROG
make blas-profile [PROG=./benchmarks/conv2d_example.py]

# Profile libtorch_python.so on PROG
make torch-profile  [PROG=./benchmarks/conv2d_example.py]

# General
LD_PROFILE=<libfoo.so> LD_PROFILE_PATH=<path-to-dir-containing-foo> make profile PROG=<python script>
```
