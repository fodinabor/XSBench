#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
OUTPUT_FILE="$SCRIPT_DIR/results.$(date -Iseconds).out"

. ../../inputgen-llvm-main/scripts/enable.sh /usr/WS1/$USER/opt/input-gen-main-quartz

#make clean
make -j4 default

llvm-link Simulation.o Main.o io.o GridInit.o XSutils.o Materials.o -o mod.bc
llvm-link Simulation.opt Main.opt io.opt GridInit.opt XSutils.opt Materials.opt -o modopt.bc

export VERBOSE=1
export TIMING=1

mkdir -p /tmp/$USER/XS0/
input-gen mod.bc --output-dir=/tmp/$USER/XS0/ --input-gen-runtime=/usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-input-gen.cpp --input-run-runtime=/usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-run.cpp 
clang++ "-ldl" "-rdynamic" /tmp/$USER/XS0//input-gen.module.generate.bc /usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-input-gen.cpp "-o" "/tmp/$USER/XS0//input-gen.module.generate.a.out" "-O1" "-DNDEBUG"  -march=native
clang++ "-ldl" "-rdynamic" /tmp/$USER/XS0//input-gen.module.run.bc /usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-run.cpp "-o" "/tmp/$USER/XS0//input-gen.module.run.a.out" "-O1" "-DNDEBUG"  -march=native


for i in $(seq 0 30); do
time /tmp/$USER/XS0/input-gen.module.generate.a.out /tmp/$USER/XS0/ $i $(($i + 1)) --file /tmp/$USER/XS0/available_functions 6
time /tmp/$USER/XS0/input-gen.module.run.a.out /tmp/$USER/XS0/input-gen.module.generate.a.out.input.6.$i.bin --file /tmp/$USER/XS0/available_functions 6
echo -n $i >> $OUTPUT_FILE
time /tmp/$USER/XS0/input-gen.module.run.a.out /tmp/$USER/XS0/input-gen.module.generate.a.out.input.6.$i.bin --file /tmp/$USER/XS0/available_functions 6 | grep "Time for IRRun" | sed "s/Time for IRRun://" >> $OUTPUT_FILE
done

./XSBench -s small | grep "Runtime" >> $OUTPUT_FILE
./XSBench | grep "Runtime" >> $OUTPUT_FILE

echo "---- O3 -----" >> $OUTPUT_FILE

mkdir -p /tmp/$USER/XS1/
input-gen modopt.bc --output-dir=/tmp/$USER/XS1/ --input-gen-runtime=/usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-input-gen.cpp --input-run-runtime=/usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-run.cpp 
clang++ "-ldl" "-rdynamic" /tmp/$USER/XS1//input-gen.module.generate.bc /usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-input-gen.cpp "-o" "/tmp/$USER/XS1//input-gen.module.generate.a.out" "-O3" "-DNDEBUG"  -march=native
clang++ "-ldl" "-rdynamic" /tmp/$USER/XS1//input-gen.module.run.bc /usr/WS1/$USER/inputgen-llvm-main/input-gen-runtimes/rt-run.cpp "-o" "/tmp/$USER/XS1//input-gen.module.run.a.out" "-O3" "-DNDEBUG"  -march=native

for i in $(seq 0 30); do
time /tmp/$USER/XS1/input-gen.module.generate.a.out /tmp/$USER/XS1/ $i $(($i + 1)) --file /tmp/$USER/XS1/available_functions 6
time /tmp/$USER/XS1/input-gen.module.run.a.out /tmp/$USER/XS1/input-gen.module.generate.a.out.input.6.$i.bin --file /tmp/$USER/XS1/available_functions 6
echo -n $i >> $OUTPUT_FILE
time /tmp/$USER/XS1/input-gen.module.run.a.out /tmp/$USER/XS1/input-gen.module.generate.a.out.input.6.$i.bin --file /tmp/$USER/XS1/available_functions 6 | grep "Time for IRRun" | sed "s/Time for IRRun://" >> $OUTPUT_FILE
done

./XSBench.opt -s small | grep "Runtime" >> $OUTPUT_FILE
./XSBench.opt | grep "Runtime" >> $OUTPUT_FILE
