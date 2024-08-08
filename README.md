# MIPS_SINGLE_CYCLE_VERSION

# Description:
This project represents a working Microprocessor without Interlocked Pipeline Stages (MIPS) which is based on the Pipeline Architecture. 
The Microprocessor architecture is created in Vivado (written in VHDL), and has 5 main stages: Instruction Fetch, Instruction Decode, Execution Unit, Memory Stage, and Write Back. 
All these are necessary to help the instruction written in the ROM memory (machine code translated from assembly) to be parsed and used correctly. 

# Single Cycle:
For the single cycle version no additional registers were used. Everything happens in one clock cycle. This version is used for simplicity and when the clock frequency is lower.

# Representative Image:
![image](https://github.com/user-attachments/assets/9e906b37-4466-4b5a-94cc-a4dfd4be876e)
