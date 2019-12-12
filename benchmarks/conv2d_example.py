import torch
import torch.nn as nn

torch.manual_seed(0)

m = nn.Conv2d(16, 8, 8, stride=2)
input = torch.randn(4, 16, 1024, 1024)
output = m(input)

print(output.sum())
