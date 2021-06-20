# plct-machine

## 介绍

`plct-machine` 是基于 `qemu`， `RISCV`的虚拟开发板， 开发者可以在其上跑目前`RISCV`大多数扩展的可执行文件， 省去了寻找不同`qemu`版本运行的麻烦， 一次编译，多种环境运行。


## 特性

支持运行以下扩展的`RISCV`可执行文件:

- P扩展

- [K扩展](https://github.com/riscv/riscv-crypto)

- [B扩展](https://github.com/riscv/riscv-bitmanip)

- [Zfinx扩展](https://github.com/riscv/riscv-zfinx)

- [RVV1.0](https://github.com/riscv/riscv-v-spec)

## 构建

这意味着我们可以这样使用

64位:
```
$ git clone -b plct-machine-dev https://github.com/isrc-cas/plct-qemu.git
$ cd plct-qemu
$ mkdir build
$ cd build
$ ../configure --target-list=riscv64-linux-user,riscv64-softmmu
$ make
$ ./qemu-riscv64 -cpu plct-u64 <your elf>
```

32位:

```
$ git clone -b plct-machine-dev https://github.com/isrc-cas/plct-qemu.git
$ cd plct-qemu
$ mkdir build
$ cd build
$ ../configure --target-list=riscv32-linux-user,riscv32-softmmu
$ make
$ ./qemu-riscv32 -cpu plct-u32 <your elf>
```

## 使用

针对不同的扩展，我们需要在运行时添加一些选项(以64位,`QEMU`用户态为例)
 
当然也可以在Linux下执行，这时需要用9p将本地文件映射到Linux下


`P` 扩展:
```
$ ./qemu-riscv64 -cpu plct-u64，x-p=true,Zpsfoperand=true,pext_spec=v0.9.4 <your elf>
$ ./qemu-riscv32 -cpu plct-u32，x-p=true,Zpsfoperand=true,pext_spec=v0.9.4 <your elf>
```

`K` 扩展:
```
$ ./qemu-riscv64 -cpu plct-u64,x-k=true,x-b=true <your elf>
$ ./qemu-riscv32 -cpu plct-u32,x-k=true,x-b=true <your elf>
```

`B`扩展:
```
$ ./qemu-riscv64 -cpu plct-u64,x-b=true <your elf>
$ ./qemu-riscv32 -cpu plct-u32,x-b=true <your elf>
```

`Zfinx` 扩展:
```
$ ./qemu-riscv64 -cpu plct-u64,Zfinx=true <your elf>
$ ./qemu-riscv64 -cpu plct-u64,Zdinx=true <your elf>
$ ./qemu-riscv32 -cpu plct-u32,Zfinx=true <your elf>
$ ./qemu-riscv32 -cpu plct-u32,Zdinx=true <your elf>
```

`RVV1.0`:
```
$ ./qemu-riscv64 -cpu plct-u64,x-v=true <your elf>
$ ./qemu-riscv32 -cpu plct-u32,x-v=true <your elf>
```

## 测试

### `K`

获取 `toolchain`
```
$ git clone https://github.com/riscv/riscv-crypto.git
$ cd riscv-crypto
$ export RISCV_ARCH=riscv64-unknown-elf
$ source ./bin/conf.sh
$ ./tools/start-from-scratch.sh
```

为了可以执行 benchmarks
```
$ source ./bin/conf.sh
$ git submodule update --init extern/riscv-arch-test
```

#### RV64
修改 benchmarks/common.mk
```
$ cd benchmarks
$ git diff .
 diff --git a/benchmarks/common.mk b/benchmarks/common.mk
index 21a4338..7fb6cd2 100644
--- a/benchmarks/common.mk
+++ b/benchmarks/common.mk
@@ -135,8 +135,7 @@ $(call map_dis,${1},${3}) : $(call map_elf,${1},${3})
 
 $(call map_run_py,${1},-${3}) : $(call map_elf,${1},${3})
        @mkdir -p $(dir $(call map_run_py,${1},${3}))
-       $(SPIKE) --isa=$(CONF_ARCH_SPIKE) $(PK) $(call map_elf,${1},${3}) > $${@}
-       sed -i "s/^bbl loader/#/" $${@}
+       /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-k=true,x-b=true $(call map_elf,${1},${3}) > $${@}
```
修改后的文件可以在 [这里](./test/k/common64.mk) 获取

运行
```
$ pip3 install pycrypto
$ make all CONFIG=rv64-zscrypto
$ make run CONFIG=rv64-zscrypto
...
AES 128 Test 0 encrypt failed.
key == b'2b7e151628aed2a6abf7158809cf4f3c'
rk  == b'2b7e151628aed2a6abf7158809cf4f3c6a81188328aed2a6abf7158809cf4f3c2b7e151628aed2a6abf7158809cf4f3c6a81188328aed2a6abf7158809cf4f3c2b7e151628aed2a6abf7158809cf4f3c6a81188328aed2a6abf7158809cf4f3c2b7e151628aed2a6abf7158809cf4f3c6a81188328aed2a6abf7158809cf4f3c2b7e151628aed2a6abf7158809cf4f3c6a81188328aed2a6abf7158809cf4f3c2b7e151628aed2a6abf7158809cf4f3c'
pt  == b'3243f6a8885a308d313198a2e0370734'
ct  == b'0470c1bf16d094f75092bab604cb340d'
    != b'3925841d02dc09fbdc118597196a0b32'
make: *** [test/Makefile.in:45: run-test-aes_128_zscrypto_rv64] Error 1
```
RV64还有点问题

#### RV32
修改 benchmarks/common.mk
```
$ cd benchmarks
$ git diff .
diff --git a/benchmarks/common.mk b/benchmarks/common.mk
index 21a4338..4f20687 100644
--- a/benchmarks/common.mk
+++ b/benchmarks/common.mk
@@ -135,8 +135,7 @@ $(call map_dis,${1},${3}) : $(call map_elf,${1},${3})
 
 $(call map_run_py,${1},-${3}) : $(call map_elf,${1},${3})
        @mkdir -p $(dir $(call map_run_py,${1},${3}))
-       $(SPIKE) --isa=$(CONF_ARCH_SPIKE) $(PK) $(call map_elf,${1},${3}) > $${@}
-       sed -i "s/^bbl loader/#/" $${@}
+       /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv32 -cpu plct-u32,x-k=true,x-b=true $(call map_elf,${1},${3}) > $${@}
 
 TARGETS += $(call map_elf,${1},${3})
 TARGETS += $(call map_dis,${1},${3})
```
修改后的文件可以在 [这里](./test/k/common32.mk) 获取

运行
```
$ pip3 install pycrypto
$ make all CONFIG=rv32-zscrypto
$ make run CONFIG=rv32-zscrypto
...
aes_256_zscrypto_rv32.py
python3 /home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/benchmarks/rv32-zscrypto/log/test/test_block_aes_256--aes_256_zscrypto_rv32.py
aes_256_zscrypto_rv32 AES 256 Test passed. enc: 209332, dec: 210708, kse: 155938, ksd: 106084, 
```


### Zfinx

`Zfinx` 版本的测试源代码在 [这里](./test/zfinx/test-zfinx.c) 可执行测试文件在 [这个](./test/zfinx) 目录

- 选项 `Zfinx=true` 可以执行以 `Zfinx` 开头的可执行文件 `Zfinx_fp64.elf` `Zfinx_dp64.elf`等

- 选项 `Zdinx=true` 可以执行以 `Zfinx` 和 `Zdinx` 开头的可执行文件 `Zfinx_fp64.elf` `Zfinx_dp64.elf` `Zdinx_fp64.elf` `Zdinx_dp64.elf`等

#### `zfinx` 选项对于`RV64`

[zfinx_fp64.elf](./test/zfinx/zfinx_fp64.elf)
```
$ ./qemu-riscv64 -cpu plct-u64,Zfinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_fp64.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.s 1 is 1
fcvt.w.s 1 is 1
fcvt.lu.s 1 is 1
fcvt.l.s 1 is 1
fcvt.d.s 1.000000 is 1.000000
fcvt.s.wu 1.000000 is 1.000000
fcvt.s.w 1.000000 is 1.000000
fcvt.s.lu 1.000000 is 1.000000
fcvt.s.l 1.000000 is 1.000000
fcvt.s.d 1.000000 is 1.000000
```

[zfinx_dp64.elf](./test/zfinx/zfinx_dp64.elf)
```
$ ./qemu-riscv64 -cpu plct-u64,Zfinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_dp64.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.d 1 is 1
fcvt.w.d 1 is 1
fcvt.lu.d 1 is 1
fcvt.l.d 1 is 1
fcvt.s.d 1.000000 is 1.000000
fcvt.d.wu 1.000000 is 1.000000
fcvt.d.w 1.000000 is 1.000000
fcvt.d.lu 1.000000 is 1.000000
fcvt.d.l 1.000000 is 1.000000
fcvt.d.s 1.000000 is 1.000000
```

#### `zdinx` 选项对于 `RV64`

[zfinx_fp64.elf](./test/zfinx/zfinx_fp64.elf)
```
$ ./qemu-riscv64 -cpu plct-u64,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_fp64.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.s 1 is 1
fcvt.w.s 1 is 1
fcvt.lu.s 1 is 1
fcvt.l.s 1 is 1
fcvt.d.s 1.000000 is 1.000000
fcvt.s.wu 1.000000 is 1.000000
fcvt.s.w 1.000000 is 1.000000
fcvt.s.lu 1.000000 is 1.000000
fcvt.s.l 1.000000 is 1.000000
fcvt.s.d 1.000000 is 1.000000
```

[zfinx_dp64.elf](./test/zfinx/zfinx_dp64.elf)
```
$ ./qemu-riscv64 -cpu plct-u64,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_dp64.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.d 1 is 1
fcvt.w.d 1 is 1
fcvt.lu.d 1 is 1
fcvt.l.d 1 is 1
fcvt.s.d 1.000000 is 1.000000
fcvt.d.wu 1.000000 is 1.000000
fcvt.d.w 1.000000 is 1.000000
fcvt.d.lu 1.000000 is 1.000000
fcvt.d.l 1.000000 is 1.000000
fcvt.d.s 1.000000 is 1.000000
```

[zdinx_fp64.elf](./test/zfinx/zdinx_fp64.elf)
```
$ ./qemu-riscv64 -cpu plct-u64,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zdinx_fp64.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.s 1 is 1
fcvt.w.s 1 is 1
fcvt.lu.s 1 is 1
fcvt.l.s 1 is 1
fcvt.d.s 1.000000 is 1.000000
fcvt.s.wu 1.000000 is 1.000000
fcvt.s.w 1.000000 is 1.000000
fcvt.s.lu 1.000000 is 1.000000
fcvt.s.l 1.000000 is 1.000000
fcvt.s.d 1.000000 is 1.000000
```

[zdinx_dp64.elf](./test/zfinx/zdinx_dp64.elf)
```
$ ./qemu-riscv64 -cpu plct-u64,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zdinx_dp64.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.d 1 is 1
fcvt.w.d 1 is 1
fcvt.lu.d 1 is 1
fcvt.l.d 1 is 1
fcvt.s.d 1.000000 is 1.000000
fcvt.d.wu 1.000000 is 1.000000
fcvt.d.w 1.000000 is 1.000000
fcvt.d.lu 1.000000 is 1.000000
fcvt.d.l 1.000000 is 1.000000
fcvt.d.s 1.000000 is 1.000000
```

#### `zfinx` 选项对于 `RV32`

[zfinx_fp32.elf](./test/zfinx/zfinx_fp32.elf)
```
$ ./qemu-riscv32 -cpu plct-u32,Zfinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_fp32.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.s 1 is 1
fcvt.w.s 1 is 1
fcvt.lu.s 1 is 1
fcvt.l.s 1 is 1
fcvt.d.s 1.000000 is 1.000000
fcvt.s.wu 1.000000 is 1.000000
fcvt.s.w 1.000000 is 1.000000
fcvt.s.lu 1.000000 is 1.000000
fcvt.s.l 1.000000 is 1.000000
fcvt.s.d 1.000000 is 1.000000
```

[zfinx_dp32.elf](./test/zfinx/zfinx_dp32.elf)
```
$ ./qemu-riscv32 -cpu plct-u32,Zfinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_dp32.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.d 1 is 1
fcvt.w.d 1 is 1
fcvt.lu.d 1 is 1
fcvt.l.d 1 is 1
fcvt.s.d 1.000000 is 1.000000
fcvt.d.wu 1.000000 is 1.000000
fcvt.d.w 1.000000 is 1.000000
fcvt.d.lu 1.000000 is 1.000000
fcvt.d.l 1.000000 is 1.000000
fcvt.d.s 1.000000 is 1.000000
```

#### `zdinx` 选项对于 `RV32`

[zfinx_fp32.elf](./test/zfinx/zfinx_fp32.elf)
```
$ ./qemu-riscv32 -cpu plct-u32,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_fp32.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.s 1 is 1
fcvt.w.s 1 is 1
fcvt.lu.s 1 is 1
fcvt.l.s 1 is 1
fcvt.d.s 1.000000 is 1.000000
fcvt.s.wu 1.000000 is 1.000000
fcvt.s.w 1.000000 is 1.000000
fcvt.s.lu 1.000000 is 1.000000
fcvt.s.l 1.000000 is 1.000000
fcvt.s.d 1.000000 is 1.000000
```

[zfinx_dp32.elf](./test/zfinx/zfinx_dp32.elf)
```
$ ./qemu-riscv32 -cpu plct-u32,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zfinx_dp32.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.d 1 is 1
fcvt.w.d 1 is 1
fcvt.lu.d 1 is 1
fcvt.l.d 1 is 1
fcvt.s.d 1.000000 is 1.000000
fcvt.d.wu 1.000000 is 1.000000
fcvt.d.w 1.000000 is 1.000000
fcvt.d.lu 1.000000 is 1.000000
fcvt.d.l 1.000000 is 1.000000
fcvt.d.s 1.000000 is 1.000000
```

[zdinx_fp32.elf](./test/zfinx/zdinx_fp32.elf)
```
$ ./qemu-riscv32 -cpu plct-u32,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zdinx_fp32.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.s 1 is 1
fcvt.w.s 1 is 1
fcvt.lu.s 1 is 1
fcvt.l.s 1 is 1
fcvt.d.s 1.000000 is 1.000000
fcvt.s.wu 1.000000 is 1.000000
fcvt.s.w 1.000000 is 1.000000
fcvt.s.lu 1.000000 is 1.000000
fcvt.s.l 1.000000 is 1.000000
fcvt.s.d 1.000000 is 1.000000
```

[zdinx_dp32.elf](./test/zfinx/zdinx_dp32.elf)
```
$ ./qemu-riscv32 -cpu plct-u32,Zdinx=true /home/ardxwe/github/intern/plct-machine/test/zfinx/zdinx_dp32.elf
fadd 3.000000 is 3.000000
fsub -1.000000 is -1.000000
fmul 2.000000 is 2.000000
fdiv 0.500000 is 0.500000
fneg -1.000000 is -1.000000
fabs 1.000000 is 1.000000
fsqrt 1.000000 is 1.000000
fmax 2.000000 is 2.000000
fmin 1.000000 is 1.000000
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.d 1 is 1
fcvt.w.d 1 is 1
fcvt.lu.d 1 is 1
fcvt.l.d 1 is 1
fcvt.s.d 1.000000 is 1.000000
fcvt.d.wu 1.000000 is 1.000000
fcvt.d.w 1.000000 is 1.000000
fcvt.d.lu 1.000000 is 1.000000
fcvt.d.l 1.000000 is 1.000000
fcvt.d.s 1.000000 is 1.000000
```

### `RVV1.0`

使用`PLCT-LLVM`编译器

下载
```
$ git clone -b rvv-iscas https://github.com/isrc-cas/rvv-llvm.git
```

构建
```
$ cd rvv-llvm
$ mkdir build
$ cd build
$ cmake -DLLVM_TARGETS_TO_BUILD="X86;RISCV" -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_INSTALL_PREFIX=./install -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
```
生成的可执行文件在`./install`

构建工具链

```
$ git clone https://github.com/riscv/riscv-gnu-toolchain
```

或许在这之前需要安装一些软件包

Ubuntu
```
$ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```

Fedora/CentOS/RHEL OS
```
$ sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

Arch Linux
```
$ pacman -Syyu autoconf automake curl python3 mpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat
```

OS X
```
$ brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat
```

构建
```
$ cd riscv-gnu-toolchain
$ ./configure --prefix=/opt/riscv
$ make
```

下载测试代码仓库

```
$ git clone -b rvv-1.0 https://github.com/RALC88/riscv-vectorized-benchmark-suite.git
```

#### _axpy

进入目录

```
$ cd riscv-vectorized-benchmark-suite/_axpy
```

修改 `Makefile`

需要修改 `GCC_TOOLCHAIN_DIR` 和 `LLVM` 这两个变量，替换成上面我们安装的位置

```
$ cat Makefile
...
GCC_TOOLCHAIN_DIR := /opt/riscv
LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install
...
```
修改后的文件可以在 [这里](./test/v/_axpy/Makefile) 获取

编译
```
$ make vector
```

可执行文件会生成在`./bin`目录 文件可以在 [这里](./test/v/_axpy/bin/rvv-test) 获取

运行(这里 `qemu` 和  `rvv-test` 需要替换为对应的路径)

```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_axpy/bin/rvv-test 256
init_vector time: 0.002208
doing reference axpy
axpy_reference time: 0.001929
doing vector axpy
axpy_intrinsics time: 0.018190
done
Result ok !!!
```

#### _blackscholes

进入目录

```
$ cd ../_blackscholes
```

修改 `Makefile`

```
$ cat Makefile
...
GCC_TOOLCHAIN_DIR := /opt/riscv
LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install
...
```
修改后的文件可以在 [这里](./test/v/_blackscholes/Makefile) 获取

编译
```
$ make vector
```
可执行文件会生成在`./bin`目录 文件可以在 [这里](./test/v/_blackscholes/bin/rvv-test) 获取

运行
```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_blackscholes/bin/rvv-test 1 ./input/in_64K.input prices.txt
50.000000000000000000
50.000000000000000000
50.000000000000000000
Num Errors: 0
...
```

#### _canneal

进入目录

```
cd ../canneal
```

修改 `Makefile`

```
$ cat Makefile
...
GCC_TOOLCHAIN_DIR := /opt/riscv
LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install
...
```
修改的文件可以在 [这里](./test/v/_canneal/Makefile) 获取

编译
```
$ make vector
```
生成的可执行文件可以在 [这里](./test/v/_canneal/bin/canneal_vector.exe) 获取

运行
```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_canneal/bin/canneal_vector.exe 1 100 300 input/100.nets 8
PARSEC Benchmark Suite
Threadcount: 1
100 swaps per temperature step
start temperature: 300
netlist filename: input/100.nets
number of temperature steps: 8
locs created
locs assigned
netlist created. 100 elements.


Initialization took 0.03738200 secs   


thread.Run() 0.00557000 secs   
Final routing is: 4141
```

#### _particlefilter

进入目录

```
$ cd ../_particlefilter
```

修改 `Makefile`

```
GCC_TOOLCHAIN_DIR := /opt/riscv
LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install
...
```
修改后的文件可以在 [这里](./test/v/_particlefilter/Makefile) 获取

编译
```
$ make vector
```
生成的可执行文件可以在 [这里](./test/v/_particlefilter/bin/rvv-test) 获取

运行
```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_particlefilter/bin/rvv-test -x 128 -y 128 -z 2 -np 256
VIDEO SEQUENCE TOOK 0.018011
TIME TO GET NEIGHBORS TOOK: 0.000366
TIME TO GET WEIGHTSTOOK: 0.000204
TIME TO SET ARRAYS TOOK: 0.003353
TIME TO SET ERROR TOOK: 0.001447
TIME TO GET LIKELIHOODS TOOK: 0.002196
TIME TO GET EXP TOOK: 0.000384
TIME TO SUM WEIGHTS TOOK: 0.000168
TIME TO NORMALIZE WEIGHTS TOOK: 0.000064
TIME TO MOVE OBJECT TOOK: 0.000145
XE: 64.870252
YE: 64.631368
1.075158
TIME TO CALC CUM SUM TOOK: 0.000952
TIME TO CALC U TOOK: 0.000095
TIME TO CALC NEW ARRAY X AND Y TOOK: 0.000949
TIME TO RESET WEIGHTS TOOK: 0.000173
PARTICLE FILTER TOOK 0.014493
ENTIRE PROGRAM TOOK 0.032504
```

#### _pathfinder

进入目录

```
cd ../_pathfinder
```

修改 `Makefile`
```
GCC_TOOLCHAIN_DIR := /opt/riscv
LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install
...
```
修改后的文件可以在 [这里](./test/v/_pathfinder/Makefile) 获取

编译
```
$ make vector
```
生成的可执行文件可以在 [这里](./test/v/_pathfinder/bin/rvv-test) 获取

运行
```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_pathfinder/bin/rvv-test 32 32 out
cols: 32 rows: 32 
TIME TO INIT DATA: 0.001433
NUMBER OF RUNS VECTOR: 100
TIME TO FIND THE SMALLEST PATH: 0.004888
52 51 50 52 58 53 54 57 48 56 56 61 61 61 61 54 51 52 56 51 47 49 52 51 54 52 58 57 52 56 55 53 %
```

#### _streamcluster

进入目录
```
$ cd ../_streamcluster
```

修改 `Makefile`
```
GCC_TOOLCHAIN_DIR := /opt/riscv
LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install
...
```
修改后的文件可以在 [这里](./test/v/_streamcluster/Makefile) 获取

编译
```
$ make vector
```
生成的可执行文件可以在 [这里](./test/v/_streamcluster/bin/rvv-test) 获取

运行
```
$ echo >output.txt;
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_streamcluster/bin/rvv-test 3 10 128 128 128 10 none output.txt 1

PARSEC Benchmark Suite
read 128 points
...
streamCluster Kernel took 0.51349200 secs
```

#### _swaptions

进入目录
```
$ cd ../_swaptions
```

修改 `Makefile`
```
GCC_TOOLCHAIN_DIR := /opt/riscv
LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install
...
```
修改后的文件可以在 [这里](./test/v/_swaptions/Makefile) 获取

编译
```
$ make vector
```
生成的可执行文件可以在 [这里](./test/v/_swaptions/bin/rvv-test) 获取

运行
```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_swaptions/bin/rvv-test -ns 8 -sm 512 -nt 1     
PARSEC Benchmark Suite
Number of Simulations: 512,  Number of threads: 1 Number of swaptions: 8


Swaption Pricing Routine took 0.22827700 secs   
Swaption 0: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000] 
Swaption 1: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000] 
Swaption 2: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000] 
Swaption 3: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000] 
Swaption 4: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000] 
Swaption 5: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000] 
Swaption 6: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000] 
Swaption 7: [SwaptionPrice: -0.0000000000 StdError: 0.0000000000]
```
测试如此，生成对应扩展的对应文件也是如此

完整的构建，测试视频看这里[bilibili](https://www.bilibili.com/video/BV1Zb4y1Q7oX)


## 联系

- 做其他扩展的开发者，希望有 `plct-machine` 的支持
- 发现存在的 `bug`
- 任何构建，执行的问题

都可以与 `PLCT` 联系

- <wangjunqiang@iscas.ac.cn>
- <ardxwe@gmail.com>