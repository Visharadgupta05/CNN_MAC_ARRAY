import torch

# Load the matrix exported from Vivado simulation
matrix = torch.tensor(
    [
        [float(value) for value in line.split()]
        for line in open("mac_output.txt")
        if line.strip()
    ],
    dtype=torch.float32
)

print("Original MAC Output:")
print(matrix)

print("\nReLU:")
print(torch.relu(matrix))

print("\nSigmoid:")
print(torch.sigmoid(matrix))

print("\nTanh:")
print(torch.tanh(matrix))

print("\nSoftmax (row-wise):")
print(torch.softmax(matrix, dim=1))
