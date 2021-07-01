#!/bin/bash
# encoding: utf-8

TEST_FOLDER="$HOME/plct-machine"

if [ -d $TEST_FOLDER ]; then
  rm -rf $TEST_FOLDER
fi

mkdir -p $TEST_FOLDER
cd $TEST_FOLDER

# qemu
git clone -b plct-machine-dev https://yt.droid.ac.cn/whale/plct-qemu.git
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

cd $TEST_FOLDER
git clone https://github.com/ArdxWe/intern.git
