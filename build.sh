#!/bin/bash
# run_fixed_simulation.sh

echo "Cleaning old files..."
rm -rf work
rm -f waveform.fst

echo "Creating work directory..."
mkdir -p work

echo "Compiling VHDL files..."
ghdl -a --workdir=work --std=08 src/image_processor.vhd
ghdl -a --workdir=work --std=08 tb/image_processor_tb.vhd

echo "Elaborating design..."
ghdl -e --workdir=work --std=08 working_tb

echo "Running simulation..."
ghdl -r --workdir=work --std=08 working_tb --fst=waveform.fst

echo "Simulation complete! Opening waveform viewer..."
gtkwave waveform.fst waveform.gtkw &