# Pytorch Backend
Repo to experiment with PyTorch backends

Get the source:
```
git clone https://github.com/vb000/pytorch-backend.git
git submodule update --init --recursive
```

Installation targets:
```
make openblas-install # Builds and installs openblas in ./OpenBLAS/build dir
make pytorch-install # Build and install PyTorch; make sure to be desired conda enviroment

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
