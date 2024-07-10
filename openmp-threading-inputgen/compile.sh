#!/usr/bin/env bash

. enable.sh /usr/WS1/ivanov2/opt/input-gen-release/

#make clean
make

llvm-link Simulation.o Main.o io.o GridInit.o XSutils.o Materials.o -o mod.bc
