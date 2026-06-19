import numpy as np
import torch
import torch.nn.functional as F

feature_map = np.loadtxt("mac_output.txt")

feature_map = torch.tensor(feature_map, dtype=torch.float32)

print("Input Feature Map:")
print(feature_map)

relu_out = F.relu(feature_map)

print("\nReLU Output:")
print(relu_out)

print("\nSigmoid Output:")
print(torch.sigmoid(feature_map))

print("\nTanh Output:")
print(torch.tanh(feature_map))

print("\nSoftmax Output:")
print(torch.softmax(feature_map.flatten(), dim=0).reshape(3,3))