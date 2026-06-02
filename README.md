# SPI Protocol Verification using SystemVerilog

## Overview

This project implements and verifies a Serial Peripheral Interface (SPI) communication system consisting of an SPI Master and SPI Slave. The verification environment is developed using SystemVerilog object-oriented testbench components including Generator, Driver, Monitor, Scoreboard, and Environment.

## Features

* SPI Master and SPI Slave RTL design
* Serial data transmission using MOSI line
* Automatic chip-select (CS) control
* Randomized test stimulus generation
* Self-checking scoreboard-based verification
* Mailbox-based communication between verification components
* Functional validation of transmitted and received data

## Design Architecture

### SPI Master

* Generates SPI clock (SCLK)
* Controls Chip Select (CS)
* Serially transmits 8-bit input data through MOSI

### SPI Slave

* Receives serial data on each SCLK edge
* Reconstructs the transmitted byte
* Generates a DONE signal after successful reception

## Verification Components

### Generator

Creates randomized 8-bit data transactions.

### Driver

Applies generated transactions to the DUT and initiates SPI transfers.

### Monitor

Captures received data from the SPI Slave.

### Scoreboard

Compares transmitted and received data and reports PASS/FAIL status.

### Environment

Connects and controls all verification components.

## Verification Flow

Generator → Driver → SPI DUT → Monitor → Scoreboard

The scoreboard compares the transmitted data with the received data and reports whether the transaction is matched or mismatched.

## Tools Used

* SystemVerilog
* EDA Playground / ModelSim / QuestaSim / Vivado Simulator
* VCD Waveform Viewer

## Simulation Result

Random SPI transactions are generated and transmitted from the Master to the Slave. The scoreboard automatically verifies the correctness of data transfer by comparing sent and received bytes.

## Project Structure

  SPI_master.sv
├── SPI_slave.sv
├── SPI_top.sv
├── SPI_interface.sv
├── testbench.sv
├── dump.vcd
├── README.md 

## Conclusion

The project successfully demonstrates SPI communication and verification using a reusable SystemVerilog testbench architecture. The self-checking environment ensures accurate validation of data transfer between SPI Master and SPI Slave modules.
