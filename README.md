# AMBA AXI3 Verification IP (VIP)
This project presents a Verification IP (VIP) developed for the AMBA AXI3 protocol, widely used in System-on-Chip (SoC) design to enable high-performance communication between master and slave components. The VIP provides reusable, configurable verification components that help validate AXI-based designs efficiently.
Key Features
  •	AXI3 Protocol Support (5 Channels: AW, W, B, AR, R)
  •	Master and Slave Agents with configurable interfaces
  •	Transaction-Level Modeling using sequence items and sequences
  •	Scoreboard for end-to-end data integrity checking
  •	Monitor for protocol activity extraction
  •	Assertions (SVA) for protocol compliance
  •	Functional Coverage to measure verification completeness
  •	Perl-based automation scripts (instead of Makefile)
Why AXI3?
AXI3 is part of the ARM AMBA bus family, supporting:
  •	High data throughput
  •	Burst transfers (INCR, FIXED, WRAP)
  •	Out-of-order transaction support
  •	Separate read/write channels for parallelism
How to Run
1.	Configure simulator environment variables
2.	Execute Perl run script:
3.	command: perl axi.pl
4.	View waveform & coverage outputs in /docs.
