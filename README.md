# CNN MAC Array Accelerator in SystemVerilog

## Overview

This project implements a 3×3 MAC (Multiply-Accumulate) processing element array for CNN convolution using SystemVerilog. The design performs convolution on a 5×5×3 input feature map with a 3×3×3 kernel and generates a 3×3 output feature map.

The architecture consists of 9 parallel processing elements (PEs). Partial sums are propagated between PEs in a pipelined manner, enabling efficient accumulation of convolution results across multiple clock cycles.

The generated feature map is exported from Vivado simulation and interfaced with PyTorch for activation function evaluation.

I have also shared the images related to the project
---

## Features

* SystemVerilog implementation
* 3×3 MAC processing element array
* 5×5×3 input feature map
* 3×3×3 convolution kernel
* 3×3 output feature map
* FSM-based control logic
* Pipelined partial-sum propagation
* Vivado simulation and verification
* PyTorch integration for activation functions

---

## Architecture

Input Feature Map (5×5×3)

↓

3×3 MAC Processing Element Array

↓

Partial Sum Accumulation

↓

Output Feature Map (3×3)

↓

Export to Text File

↓

PyTorch Activation Functions (ReLU, Sigmoid, Tanh, Softmax)

---

## Output Example

90 99 108

135 144 153

180 189 198

---

## Tools Used

* SystemVerilog
* Xilinx Vivado
* Python
* PyTorch

---

## Project Structure

```text
MAC_DESIGN/
├── mac_2_systolic.sv
├── mac_2_systolic_tb.sv
├── activation.py
├── mac_output.txt
└── README.md
```

---

## Future Improvements

* Hardware ReLU implementation
* Max Pooling layer
* Fully streaming systolic dataflow
* FPGA deployment and hardware validation

---


