#!/bin/bash
# encoding: utf-8

TEST_FOLDER="$HOME/plct-machine"
RESULT="$TEST_FOLDER/result.txt"

if [ -d $TEST_FOLDER ]; then
  rm -rf $TEST_FOLDER
fi

mkdir -p $TEST_FOLDER
cd $TEST_FOLDER

# qemu
git clone -b new-machine-dev https://github.com/isrc-cas/plct-qemu.git
cd plct-qemu

mkdir build-64
cd build-64
../configure --target-list=riscv64-linux-user,riscv64-softmmu
make -j$(nproc)

cd ..
mkdir build-32
cd build-32
../configure --target-list=riscv32-linux-user,riscv32-softmmu
make -j$(nproc)

# K
cd $TEST_FOLDER
git clone https://github.com/ArdxWe/riscv-crypto.git
cd riscv-crypto
export RISCV_ARCH=riscv64-unknown-elf
source ./bin/conf.sh
./tools/start-from-scratch.sh


# run benchmarks
cd benchmarks
git submodule update --init extern/riscv-arch-test
pip3 install pycrypto

git checkout qemu-riscv64
make all CONFIG=rv64-zscrypto
make run CONFIG=rv64-zscrypto

git checkout qemu-riscv32
make all CONFIG=rv32-zscrypto
make run CONFIG=rv32-zscrypto

# Zfinx
cd $TEST_FOLDER
git clone https://github.com/ArdxWe/intern.git

echo "-----------------------------Zfinx Test-----------------------------"

echo "zfinx_fp64.elf Zfinx=true for qemu-riscv64" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp64.elf >> $RESULT 2>&1

echo "zfinx_dp64.elf Zfinx=true for qemu-riscv64" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp64.elf >> $RESULT 2>&1

echo "zfinx_fp64.elf Zdinx=true for qemu-riscv64" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp64.elf >> $RESULT 2>&1
echo "zfinx_dp64.elf Zdinx=true for qemu-riscv64" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp64.elf >> $RESULT 2>&1
echo "zdinx_fp64.elf Zdinx=true for qemu-riscv64" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_fp64.elf >> $RESULT 2>&1
echo "zdinx_dp64.elf Zdinx=true for qemu-riscv64" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_dp64.elf >> $RESULT 2>&1

echo "zfinx_fp32.elf Zfinx=true for qemu-riscv32" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp32.elf >> $RESULT 2>&1
echo "zfinx_dp32.elf Zfinx=true for qemu-riscv32" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp32.elf >> $RESULT 2>&1

echo "zfinx_fp32.elf Zdinx=true for qemu-riscv32" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp32.elf >> $RESULT 2>&1
echo "zfinx_dp32.elf Zdinx=true for qemu-riscv32" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp32.elf >> $RESULT 2>&1
echo "zdinx_fp32.elf Zdinx=true for qemu-riscv32" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_fp32.elf >> $RESULT 2>&1
echo "zdinx_dp32.elf Zdinx=true for qemu-riscv32" >> $RESULT 2>&1
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_dp32.elf >> $RESULT 2>&1


# RVV

# for ubuntu
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

# build PLCT-LLVM
cd $TEST_FOLDER
git clone -b rvv-iscas https://github.com/isrc-cas/rvv-llvm.git
cd rvv-llvm
mkdir build
cd build
cmake -DLLVM_TARGETS_TO_BUILD="X86;RISCV" -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_INSTALL_PREFIX=./install -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm

# build toolchain
cd $TEST_FOLDER
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=$TEST_FOLDER/riscv
make -j$(nproc)

# riscv-vectorized-benchmark-suite
cd $TEST_FOLDER
git clone -b rvv-1.0 https://github.com/ArdxWe/riscv-vectorized-benchmark-suite.git

# run
cd $TEST_FOLDER/riscv-vectorized-benchmark-suite/_axpy
make vector
make runqemu

cd $TEST_FOLDER/riscv-vectorized-benchmark-suite/_blackscholes
make vector
make runqemu

cd $TEST_FOLDER/riscv-vectorized-benchmark-suite/_canneal
make vector
make runqemu

cd $TEST_FOLDER/riscv-vectorized-benchmark-suite/_particlefilter
make vector
make runqemu

cd $TEST_FOLDER/riscv-vectorized-benchmark-suite/_pathfinder
make vector
make runqemu

cd $TEST_FOLDER/riscv-vectorized-benchmark-suite/_streamcluster
make vector
make runqemu
