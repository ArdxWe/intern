#!/bin/bash
# encoding: utf-8

TEST_FOLDER="~/plct-machine"

echo "cd to TEST_FOLDER"
if [ -d "$TEST_FOLDER" ]; then
  rm -rf "$TEST_FOLDER"
else
  mkdir -p "$TEST_FOLDER"
fi

cd "$TEST_FOLDER"

# qemu
echo "clone qemu"
git clone -b new-machine-dev https://github.com/isrc-cas/plct-qemu.git
cd plct-qemu

echo "build qemu-riscv64"
mkdir build-64
cd build-64
../configure --target-list=riscv64-linux-user,riscv64-softmmu
make -j$(nproc)

cd ..

echo "build qemu-riscv32"
mkdir build-32
cd build-32
../configure --target-list=riscv32-linux-user,riscv32-softmmu
make -j$(nproc)

cd ...

# K
echo "start K test"

echo "git clone https://github.com/ArdxWe/riscv-crypto.git"
git clone https://github.com/ArdxWe/riscv-crypto.git
cd riscv-crypto

echo "build k-toolchain"
export RISCV_ARCH=riscv64-unknown-elf
source ./bin/conf.sh
./tools/start-from-scratch.sh


echo "run benchmarks"
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

cd "$TEST_FOLDER"
git clone https://github.com/ArdxWe/intern.git

echo "Zfinx=true for qemu-riscv64"
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp64.elf
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp64.elf

echo "Zdinx=true for qemu-riscv64"
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp64.elf
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp64.elf
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_fp64.elf
$TEST_FOLDER/plct-qemu/build-64/qemu-riscv64 -cpu plct-u64,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_dp64.elf

echo "Zfinx=true for qemu-riscv32"
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp64.elf
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zfinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp64.elf

echo "Zdinx=true for qemu-riscv32"
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_fp64.elf
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zfinx_dp64.elf
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_fp64.elf
$TEST_FOLDER/plct-qemu/build-32/qemu-riscv32 -cpu plct-u32,Zdinx=true $TEST_FOLDER/intern/plct-machine/test/zfinx/zdinx_dp64.elf
