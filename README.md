# Pytorch Backend
Repo to experiment with PyTorch backends

Get the source:
```
git clone https://github.com/vb000/pytorch-backend.git
git submodule update --init --recursive
```

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
python cond2d_example.py # Simple conv2d operation to understand the call stack
```

Profiling (using `sprof`):
```
make blas-profile # Profile libopenblas.so on ./conv2d_exmaple
make torch-profile # Profile libtorch_python.so on ./conv2d_example.py
```
