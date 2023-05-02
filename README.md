# Two-Level-Multiplier

This repository contains the source code for a VHDL implementation of the multiplication algorithm using a two-level hardware structure proposed in the paper "Leveraging a Novel Two-Level Priority Encoder for High-Precision Integer Multiplication." It contains several prefabricated sizes of square multipliers, as well as a C++ program to generate most components of new multipliers. The exception is carry-look-ahead adders and small priority encoders, which can be created from existing files.

The 'Software Simulator' folder also contains a high-level simulation of the multiplication algorithm, written in Kotlin. You can also test it easily online on Kotlin Playground here: [https://pl.kotl.in/j2RgjnehS](https://pl.kotl.in/j2RgjnehS).

The 'Output Postprocessor' folder contains a Kotlin program useful for managing the input and output of an FPGA board running the VHDL code. For instance, removing non-digit characters like spaces or commas.

The following resources are also useful when testing the hardware:
- [Random 256-Bit Number Generator](https://numbergenerator.org/random-256-bit-binary-number) (similar generators are also available for higher input lengths)
- [High Precision Base Converter](https://baseconvert.com/high-precision)
- [Big Number Calculator](https://www.calculator.net/big-number-calculator.html) (Warning: truncates past ~4096-bit operands)

## Example
Below is an illustrative example with a small input size of our algorithm and the first two cycles of the hardware.

![example.png](https://github.com/ALUminaries/Two-Level-Multiplier/main/Illustrative%20Example.png)
