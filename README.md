SystemVerilog D Flip-Flop — OOP Testbench Verification
Overview
This project implements and verifies a D Flip-Flop design using SystemVerilog with an Object-Oriented Testbench architecture.
The verification environment uses classes, mailboxes, events, and virtual interfaces to model a reusable, modular verification setup similar to UVM concepts, but without the full UVM framework.

Design Under Test (DUT)
Module: top
Implements a positive-edge triggered D Flip-Flop:

On reset (rst=1): output dout is set to 0.

On rising clock edge: dout follows din.

Interface: dff_if

Signals: clk, rst, din, dout

Shared between DUT and Testbench for easy connectivity.

Testbench Architecture
The Testbench is fully class-based and follows a layered OOP structure:

1. transaction
Holds a single-bit input (din) and output (dout).

Includes a copy() method to duplicate transactions safely.

Includes a display() method for debug printing.

2. generator
Randomly generates stimulus transactions.

Sends transactions to both:

Driver (for driving DUT inputs).

Scoreboard (as golden reference data).

Synchronizes with scoreboard using events.

3. driver
Retrieves transactions from the generator via a mailbox.

Drives din into DUT through the virtual interface.

Performs a reset at the start of simulation.

4. monitor
Observes DUT output signals through the interface.

Sends captured transactions to the scoreboard.

5. scoreboard
Compares DUT output (dout) with golden reference (din from generator).

Reports PASS if matched, FAIL if mismatched.

6. environment
Instantiates generator, driver, monitor, and scoreboard.

Connects them via mailboxes and events.

Controls the simulation flow: pre_test() → test() → post_test().

Simulation Flow
Reset Phase — driver applies reset to DUT.

Stimulus Phase — generator creates random inputs, sends them to driver and scoreboard.

Driving Phase — driver applies din to DUT.

Monitoring Phase — monitor captures DUT outputs.

Checking Phase — scoreboard compares DUT output with reference.

End Simulation — Stops when all transactions are processed.

How to Run on EDA Playground
Go to EDA Playground.

Select SystemVerilog as the language.

Choose a simulator supporting OOP features (e.g., Questa, VCS).

Paste DUT, interface, and Testbench code into the editor.

Set Top Module Name to tb.

Enable VCD dump for waveform viewing.

Run simulation and check:

Console output for PASS/FAIL messages.

Waveform in GTKWave to visualize DFF behavior.

Key Learnings
Using mailboxes for inter-component communication.

Synchronization between generator and scoreboard using events.

Avoiding transaction aliasing with deep copy methods.

Layered OOP Testbench design similar to UVM concepts.
