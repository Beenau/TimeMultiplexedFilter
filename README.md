# TimeMultiplexedFilter
Coded in System Verilog

Creates a time multiplexed FIR filter.  Filter MUX controls can be expanded for higher order FIR filter.  Initialized to 2nd order.

Desined with miniZed hardware in mind.

#.m File
This is the matlab script that handles device communication, fixed point data creation, and conversion from recieved hex characters back to fixed point.  This script also plots the analysis of the hardware accuracy and the difference between the fixed point calculations capable in this system verilog architecture and the more accurate floating point calculations done in matlab.

# .dat Files
These files provide coefficients and some sample inputs in signed binary format
