import torch
import torch.nn as nn

torch.manual_seed(0)

m = nn.Conv2d(16, 33, 3, stride=2)
input = torch.randn(20, 16, 50, 100)
output = m(input)

print(output.sum())
