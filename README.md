# Two-Level-Multiplier

This repository contains source code for a VHDL implementation of the high-precision integer multiplication algorithm proposed in the paper "[Leveraging a Novel Two-Level Priority Encoder for High-Precision Integer Multiplication](https://doi.org/10.1109/MWSCAS57524.2023.10405960)." All components are generalized such that only generics need modified to adapt the hardware to different bit precisions.

### Files

- For implementation and on-board testing, all files in `/src` and subdirectories are required.
  - Technically, not all of the small encoder components in `/src/Base Encoders` are needed depending on bit precision, but if you are switching between bit precisions it is recommended to simply import all of them, as `priority_encoder_generic` will only instantiate the necessary components.
  - To adjust for different bit precisions, modify the generics in the top-level file.
  - Constraint files for Digilent Basys 3 and Nexys A7-100T FPGA development boards are located in `/src/XCVR`. For other devices, adapt these constraints appropriately.
  - For uneven multipliers, slight modification is necessary to `mk8_container_multiplier_####.vhd` and `mk8_apex_####.vhd` to set the generic from the top-level file instead of dividing the top-level `G_total_bits` by 2 to get `G_n` and `G_m`.
- For synthesis and simulation *only*, the files in `/src/XCVR` are not required. Everything else is as stated above.
- The 'Software Simulator' folder contains a high-level simulation of the multiplication algorithm, written in Kotlin. You can also test it easily online on Kotlin Playground here: [https://pl.kotl.in/j2RgjnehS](https://pl.kotl.in/j2RgjnehS).
- The 'Output Postprocessor' folder contains a Kotlin program useful for managing the input and output of an FPGA board running the VHDL code. For instance, removing non-digit characters like spaces or commas.
- Note: the code provided implements our [serial transceiver, which can be found here](https://github.com/ALUminaries/Serial-Transceiver).

### Other 
The following resources are useful when testing the hardware:
- [Random 256-Bit Number Generator](https://numbergenerator.org/random-256-bit-binary-number) (similar generators are also available for higher input lengths)
- [High Precision Base Converter](https://baseconvert.com/high-precision)
- [Big Number Calculator](https://www.calculator.net/big-number-calculator.html) (Warning: truncates past ~4096-bit operands)

### Example
Below is an illustrative example with a small input size of our algorithm and the first two cycles of the hardware.

![example.png](https://github.com/ALUminaries/Two-Level-Multiplier/blob/main/Illustrative%20Example.png)
