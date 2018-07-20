# RISC-V CPU System

Noname is a 32 bits microcontroller class device that implements a CPU core based on the [RISC-V 32I Instruction Set](http://riscv.org/)


## Table of Contents

* [RISC-V CPU System](#risc-v-cpu-system)
	* [Processor Details](#processor-details)
	* [Software Details](#software-details)
	* [Directory Layout](#directory-layout)
	* [Simulation](#simulation)
		* [Compile assembly tests and benchmarks](#compile-assembly-tests-and-benchmarks)
		* [Simulate the CPU](#simulate-the-cpu)


## Processor Details

- 32-bit microcontroller class device: M mode only no memory protection.

- Single-issue in-order 5-stage pipeline, with full forwarding and hazard detection.

- RISC-V RV32I ISA v2.2, and priviledge mode v1.10.

- Exception/Interrupt handling.

- Two memory ports: [Wishbone B4](https://www.ohwr.org/attachments/179/wbspec_b4.pdf) interface.


## Software Details

- [Verilator](https://www.veripool.org/wiki/verilator) for simulation
- A [RISC-V toolchain](http://riscv.org/software-tools/) to compile the validation tests and benchmarks


## Directory Layout

````
.
├── hardware         : CPU source files written in Verilog
├── tests            : Test environment for the CPU
│   ├── benchmarks     : Basic benchmarks written in C
│   ├── extra-tests    : Basic interrupts test
│   ├── riscv-tests    : Basic instruction-level tests
│   └── verilator      : C++ testbench for the CPU validation
├── Makefile
└── README.md
````


## Simulation

### Compile assembly tests and benchmarks

To compile the RISC-V instruction-level tests, benchmarks and extra-tests:

`make compile-tests`

### Simulate the CPU

- To execute all the tests, without VCD dumps:

`make run-tests`

- To execute the C++ model with a single `.elf` file:

`Noname.exe --file [ELF file] --timeout [max simulationtime] --trace (optional)`