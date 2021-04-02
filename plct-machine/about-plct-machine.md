# plct-machine

## 介绍

`plct-machine` 是基于 `qemu`， `RISCV`的虚拟开发板， 开发者可以在其上跑目前`RISCV`大多数扩展的可执行文件， 省去了寻找不同`qemu`版本运行的麻烦， 一次编译，多种环境运行。


## 特性

支持运行以下扩展的`RISCV`可执行文件:

- [P扩展](https://github.com/romanheros/qemu/tree/packed-upstream-v1)

- [K扩展](https://github.com/isrc-cas/plct-qemu/tree/plct-k-dev)

- [B扩展](https://github.com/sifive/qemu/tree/rvb-upstream-v4)

- [Zfinx扩展](https://github.com/isrc-cas/plct-qemu/tree/plct-zfinx-dev)

- [RVV1.0](https://github.com/sifive/qemu/tree/rvv-1.0-upstream-v7-vfredosum)

## 构建
这意味着我们可以这样使用

64位:
```
$ git clone -b new-machine-dev https://github.com/isrc-cas/plct-qemu.git
$ mkdir build
$ cd build
$ ../configure --target-list=riscv64-linux-user,riscv64-softmmu
$ make
$ ./qemu-riscv64 -cpu plct-u64 <your elf>
```

32位:

```
$ git clone -b new-machine-dev https://github.com/isrc-cas/plct-qemu.git
$ mkdir build
$ cd build
$ ../configure --target-list=riscv32-linux-user,riscv64-softmmu
$ make
$ ./qemu-riscv32 -cpu plct-u32 <your elf>
```

## 使用

 针对不同的扩展，我们需要在执行的时候添加一些选项(以64位,`QEMU`用户态为例)
 
 当然也可以在Linux下执行，这时需要用9p来做文件映射， 将本地文件映射到Linux下


`P` 扩展:
 ```
 $ ./qemu-riscv64 -cpu plct-u64,x-p=true,Zp64=true,pext_spec=v0.9.2 <your elf>
 ```

 `K` 扩展:
 ```
 $ ./qemu-riscv64 -cpu plct-u64,x-k=true <your elf>
 ```

 `B`扩展:
 ```
 $ ./qemu-riscv64 -cpu plct-u64,x-b=true <your elf>
 ```

 `Zfinx` 扩展:
```
$ ./qemu-riscv64 -cpu plct-u64,Zfinx=true <your elf>
```

`RVV1.0`:
```
$ ./qemu-riscv64 -cpu plct-u64,x-v=true <your elf>
```

## 测试

|   扩展              | 测试代码                  |
| :------------:     | :---------------: |
| `P`             | [test-p.c](./test/test-p.c)|
| `K`             | [repo](https://github.com/rvkrypto/rvkrypto-fips) |
| `B`             | [repo](https://github.com/rvkrypto/rvkrypto-fips) |
| `Zfinx`         | [test-zfinx.c](./test/test-zfinx.c) |
| `RVV1.0` | [repo](https://github.com/RALC88/riscv-vectorized-benchmark-suite/tree/rvv-1.0) |

### `P`

使用普通版本的工具链就可以

```
$ git clone https://github.com/riscv/riscv-gnu-toolchain
$ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
$ cd riscv-gnu-toolchain
$ ./configure --prefix=/opt/riscv
$ make
```

可以确认一下 gcc位置

```
$ where riscv64-unknown-elf-gcc       
/home/ardxwe/PLCT/Bin/riscv64/bin/riscv64-unknown-elf-gcc
```

编译`p`扩展测试代码[test-p.c](./test/test-p.c)

```
$ riscv64-unknown-elf-gcc test-p.c -O1 -o p
```

使用我们这个版本编译生成的`QEMU`路径执行

```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-p=true,Zp64=true,pext_spec=v0.9.2 ~/PLCT/Code/p
add32 result: 0x300000009
add   result: 0x300000009
result OK !!!
```

### `K` 和 `B`



想要去获得`K`和`B`扩展可执行文件， 我们需要构建`K`扩展工具链

```
$ git clone https://github.com/riscv/riscv-crypto.git
```

进入存储库

```
$ cd riscv-crypto
```

添加临时环境变量

```
$ export RISCV_ARCH=riscv64-unknown-elf
```

执行构建`K`扩展工具链脚本,这个过程可能需要1个小时左右

```
$ source bin/conf.sh
$ ./tools/start-from-scratch.sh
```

生成的可执行文件在 `./build` 下

```
$ ls build  
riscv64-unknown-elf  riscv-pk                      riscv-pk-riscv64-unknown-elf
riscv-isa-sim        riscv-pk-riscv32-unknown-elf  toolchain
```

下载测试仓库

```
$ git clone https://github.com/rvkrypto/rvkrypto-fips
```

进入测试仓库

```
$ cd rvkrypto-fips
```

修改`test_main.c`文件，删除`test_gcm`函数
```
$ cat test_main.c
//	test_main.c
//	2021-02-13	Markku-Juhani O. Saarinen <mjos@pqshield();om>
//	Copyright (c) 2021, PQShield Ltd. All rights reserved.

//	=== Main driver for the algorithm tests.

#include "rvkintrin.h"
#include "test_rvkat.h"

//	algorithm tests

int test_aes();		//	test_aes.c
// int test_gcm();		//	test_gcm.c
int test_sha2();	//	test_sha2.c
int test_sha3();	//	test_sha3.c
int test_sm3();		//	test_sm3.c
int test_sm4();		//	test_sm4.c

//	stub main: run unit tests

int main()
{
	int fail = 0;

	fail += test_aes();
	// fail += test_gcm();
	fail += test_sha2();
	fail += test_sha3();
	fail += test_sm3();
	fail += test_sm4();

	if (fail) {
		rvkat_info("RVKAT self-test finished: FAIL (there were errors)");
	} else {
		rvkat_info("RVKAT self-test finished: PASS (no errors)");
	}

	return fail;
}
```
创建`q64.mk`配置文件路径

```
$ vim q64.mk
$ cat 164.mk
#	rv64.mk
#	2021-02-14	Markku-Juhani O. Saarinen <mjos@pqshield.com>
#   Copyright (c) 2021, PQShield Ltd.  All rights reserved.

#	===	Cross-compile for RV64 target, run with spike emulator.

#	(lacking K flag here)
CFLAGS	+=	-march=rv64imafdc -mabi=lp64d

#	toolchai
XCHAIN	=	/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-
objdump = objdump -d

QEMU    = /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-k=true,x-b=true -d in_asm

#	default target
all:	qemu	

#	include main makefile
include	Makefile

#	execution target (has b here)
qemu:	$(XBIN)
	$(QEMU) ./$(XBIN) 2>test/64.asm
	$(XCHAIN)$(objdump) ./$(XBIN) >test/64.asm.ref

```

这里可以直接复制我这里给出的`q64.mk`，但要注意：

- `XCHAIN`应该更改为你电脑的上文生成的k扩展工具链对应的gcc可执行文件的路径
- `QEMU`应该设置为我们这个版本编译生成的可执行文件路径
- 不要再做任何改动

执行测试

```
$ make -f q64.mk
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_sha3.c -o test_sha3.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_sha2.c -o test_sha2.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_sm4.c -o test_sm4.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_gcm.c -o test_gcm.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_rvkat_sio.c -o test_rvkat_sio.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_sm3.c -o test_sm3.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_aes.c -o test_aes.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c rvk_emu.c -o rvk_emu.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c test_main.c -o test_main.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sm4/sm4_rvk.c -o sm4/sm4_rvk.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c aes/aes_rvk32.c -o aes/aes_rvk32.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c aes/aes_api.c -o aes/aes_api.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c aes/aes_rvk64.c -o aes/aes_rvk64.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c aes/aes_otf_rvk64.c -o aes/aes_otf_rvk64.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c gcm/gcm_gfmul_rv32.c -o gcm/gcm_gfmul_rv32.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c gcm/gcm_gfmul_rv64.c -o gcm/gcm_gfmul_rv64.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c gcm/gcm_api.c -o gcm/gcm_api.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sm3/sm3_api.c -o sm3/sm3_api.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sm3/sm3_cf256_rvk.c -o sm3/sm3_cf256_rvk.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sha3/sha3_api.c -o sha3/sha3_api.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sha3/sha3_f1600_rvb64.c -o sha3/sha3_f1600_rvb64.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sha3/sha3_f1600_rvb32.c -o sha3/sha3_f1600_rvb32.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sha2/sha2_cf256_rvk.c -o sha2/sha2_cf256_rvk.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sha2/sha2_cf512_rvk32.c -o sha2/sha2_cf512_rvk32.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sha2/sha2_cf512_rvk64.c -o sha2/sha2_cf512_rvk64.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -c sha2/sha2_api.c -o sha2/sha2_api.o
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-gcc  -march=rv64imafdc -mabi=lp64d -Wall -Wextra -O2 -g -I.  -DRVK_ALGTEST_VERBOSE_SIO=1 -o xtest test_sha3.o test_sha2.o test_sm4.o test_gcm.o test_rvkat_sio.o test_sm3.o test_aes.o rvk_emu.o test_main.o sm4/sm4_rvk.o aes/aes_rvk32.o aes/aes_api.o aes/aes_rvk64.o aes/aes_otf_rvk64.o gcm/gcm_gfmul_rv32.o gcm/gcm_gfmul_rv64.o gcm/gcm_api.o sm3/sm3_api.o sm3/sm3_cf256_rvk.o sha3/sha3_api.o sha3/sha3_f1600_rvb64.o sha3/sha3_f1600_rvb32.o sha2/sha2_cf256_rvk.o sha2/sha2_cf512_rvk32.o sha2/sha2_cf512_rvk64.o sha2/sha2_api.o  
/home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-k=true,x-b=true -d in_asm ./xtest 2>test/64.asm
[INFO] === AES64 ===
[PASS] AES-128 Enc 69C4E0D86A7B0430D8CDB78070B4C55A
[PASS] AES-128 Dec 00112233445566778899AABBCCDDEEFF
[PASS] AES-192 Enc DDA97CA4864CDFE06EAF70A0EC0D7191
[PASS] AES-192 Dec 00112233445566778899AABBCCDDEEFF
[PASS] AES-256 Enc 8EA2B7CA516745BFEAFC49904B496089
[PASS] AES-256 Dec 00112233445566778899AABBCCDDEEFF
[PASS] AES-128 Enc 3AD77BB40D7A3660A89ECAF32466EF97
[PASS] AES-128 Dec 6BC1BEE22E409F96E93D7E117393172A
[PASS] AES-192 Enc 974104846D0AD3AD7734ECB3ECEE4EEF
[PASS] AES-192 Dec AE2D8A571E03AC9C9EB76FAC45AF8E51
[PASS] AES-256 Enc B6ED21B99CA6F4F9F153E7B1BEAFED1D
[PASS] AES-256 Dec 30C81C46A35CE411E5FBC1191A0A52EF
[INFO] === AES64 / On-the-fly keying ===
[PASS] AES-128 Enc 69C4E0D86A7B0430D8CDB78070B4C55A
[PASS] AES-128 Dec 00112233445566778899AABBCCDDEEFF
[PASS] AES-192 Enc DDA97CA4864CDFE06EAF70A0EC0D7191
[PASS] AES-192 Dec 00112233445566778899AABBCCDDEEFF
[PASS] AES-256 Enc 8EA2B7CA516745BFEAFC49904B496089
[PASS] AES-256 Dec 00112233445566778899AABBCCDDEEFF
[PASS] AES-128 Enc 3AD77BB40D7A3660A89ECAF32466EF97
[PASS] AES-128 Dec 6BC1BEE22E409F96E93D7E117393172A
[PASS] AES-192 Enc 974104846D0AD3AD7734ECB3ECEE4EEF
[PASS] AES-192 Dec AE2D8A571E03AC9C9EB76FAC45AF8E51
[PASS] AES-256 Enc B6ED21B99CA6F4F9F153E7B1BEAFED1D
[PASS] AES-256 Dec 30C81C46A35CE411E5FBC1191A0A52EF
[INFO] === SHA2-256 using sha2_cf256_rvk() ===
[PASS] SHA2-256 BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD
[PASS] SHA2-224 03842600C86F5CD60C3A2147A067CB962A05303C3488B05CB45327BD
[PASS] SHA2-256 E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855
[PASS] SHA2-256 6595A2EF537A69BA8583DFBF7F5BEC0AB1F93CE4C8EE1916EFF44A93AF5749C4
[PASS] SHA2-256 CFB88D6FAF2DE3A69D36195ACEC2E255E2AF2B7D933997F348E09F6CE5758360
[PASS] SHA2-256 42E61E174FBB3897D6DD6CEF3DD2802FE67B331953B06114A65C772859DFC1AA
[PASS] SHA2-256 3C593AA539FDCDAE516CDF2F15000F6634185C88F505B39775FB9AB137A10AA2
[INFO] === SHA2-512 using sha2_cf512_rvk64() ===
[PASS] SHA2-512 DDAF35A193617ABACC417349AE20413112E6FA4E89A97EA20A9EEEE64B55D39A2192992A274FC1A836BA3C23A3FEEBBD454D4423643CE80E2A9AC94FA54CA49F
[PASS] SHA2-512 8E959B75DAE313DA8CF4F72814FC143F8F7779C6EB9F7FA17299AEADB6889018501D289E4900F7E4331B99DEC4B5433AC7D329EEB6DD26545E96E55B874BE909
[PASS] SHA2-384 38B060A751AC96384CD9327EB1B1E36A21FDB71114BE07434C0CC7BF63F6E1DA274EDEBFE76F65FBD51AD2F14898B95B
[PASS] SHA2-384 E7089D72945CEF851E689B4409CFB63D135F0B5CDFB0DAC6C3A292DD70371AB4B79DA1997D7992906AC7213502662920
[INFO] === SHA3 using sha3_f1600_rvb64() ===
[PASS] KECCAK-P 1581ED5252B07483009456B676A6F71D7D79518A4B1965F7450576D1437B47206A60F6F3A48B5FD193D48D7C4F14D7A13FFD38519693D130BEE31B9572947E485A7ADACB58A8F30C887FB19B384EE52F8F269F0DDE38730B7F6D258BF5DFEF556A3E2CEB943E35C8111F908C94F62A2EA69D30CA0CDE73E8E2314D946CC2AFF7D715C48C80EAF5A0CFD83E7E4331F55321D2A4433B1F7F7785E999B43CA60CFD3023D1C5C055C0D4DFA7E0A68AE52FA7A348997C93F51A42880834713010165E334A7E293AF453D1
[PASS] SHA3-224 6B4E03423667DBB73B6E15454F0EB1ABD4597F9A1B078E3F5B5A6BC7
[PASS] SHA3-256 64537B87892835FF0963EF9AD5145AB4CFCE5D303A0CB0415B3B03F9D16E7D6B
[PASS] SHA3-384 D1C0FA85C8D183BEFF99AD9D752B263E286B477F79F0710B010317017397813344B99DAF3BB7B1BC5E8D722BAC85943A
[PASS] SHA3-512 6E8B8BD195BDD560689AF2348BDC74AB7CD05ED8B9A57711E9BE71E9726FDA4591FEE12205EDACAF82FFBBAF16DFF9E702A708862080166C2FF6BA379BC7FFC2
[PASS] SHAKE128 9DE6FFACF3E59693A3DE81B02F7DB77A
[PASS] SHAKE256 89F2373E131A899B4BA27F6DA606716A5E289FD530AE066BB8B11DC023DACBD6
[PASS] SHAKE128 43E41B45A653F2A5C4492C1ADD544512DDA2529833462B71A41A45BE97290B6F
[PASS] SHAKE256 AB0BAE316339894304E35877B0C28A9B1FD166C796B9CC258A064A8F57E27F2A
[PASS] SHAKE128 44C9FB359FD56AC0A9A75A743CFF6862F17D7259AB075216C0699511643B6439
[PASS] SHAKE256 6A1A9D7846436E4DCA5728B6F760EEF0CA92BF0BE5615E96959D767197A0BEEB
[INFO] === SM3 ===
[PASS] SM3-256 66C7F0F462EEEDD9D1F2D46BDC10E4E24167C4875CF2F7A2297DA02B8F4BA8E0
[PASS] SM3-256 DEBE9FF92275B8A138604889C18E5A4D6FDB70E5387E5765293DCBA39C0C5732
[INFO] === SM4 ===
[PASS] SM4 Encrypt 681EDF34D206965E86B3E94F536E4246
[PASS] SM4 Decrypt 0123456789ABCDEFFEDCBA9876543210
[PASS] SM4 Encrypt F766678F13F01ADEAC1B3EA955ADB594
[PASS] SM4 Decrypt 000102030405060708090A0B0C0D0E0F
[PASS] SM4 Encrypt 865DE90D6B6E99273E2D44859D9C16DF
[PASS] SM4 Decrypt D294D879A1F02C7C5906D6C2D0C54D9F
[PASS] SM4 Encrypt 94CFE3F59E8507FEC41DBE738CCD53E1
[PASS] SM4 Decrypt A27EE076E48E6F389710EC7B5E8A3BE5
[INFO] RVKAT self-test finished: PASS (no errors)
/home/ardxwe/PLCT/Src/k-toolchain/riscv-crypto/build/riscv64-unknown-elf/bin/riscv64-unknown-elf-objdump -d ./xtest >test/64.asm.ref
```

### `Zfinx`

应该使用 `Zfinx` 版本的`gcc`去编译[test-zfinx.c](./test/test-zfinx.c)

单精度浮点

```
$ git clone https://github.com/pz9115/riscv-gcc
$ cd riscv-gcc
$ ./configure --prefix=/opt/rv64zfinx/ --with-arch=rv64imaczfinx --with-abi=lp64 --with-abi=lp64 --with-multilib-generator="rv64imaczfinx-lp64--"
$ make
$ make install
```

双精度浮点

```
$ git clone https://github.com/pz9115/riscv-gcc
$ cd riscv-gcc
$ ./configure --prefix=/opt/rv64zfinx/ --with-arch=rv64imaczdinxzfinx --with-abi=lp64 --with-abi=lp64 --with-multilib-generator="rv64imaczdinxzfinx-lp64--"
$ make
$ make install
```

执行

```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,Zfinx=true /home/ardxwe/PLCT/Code/fp64.elf       
fadd 3.000000 is 3.0
fsub -1.000000 is -1.0
fmul 2.000000 is 2.0
fdiv 0.500000 is 0.5
fneg -1.000000 is -1.0
fabs 1.000000 is 1.0
fsqrt 1.000000 is 1.0
fmax 2.000000 is 2.0
fmin 1.000000 is 1.0
feq 0 is 0
flt 1 is 1
fle 1 is 1
fgt 0 is 0
fge 0 is 0
fcvt.wu.s 1 is 1
fcvt.w.s 1 is 1
fcvt.lu.s 1 is 1
fcvt.l.s 1 is 1
fcvt.d.s 1.000000 is 1.0
fcvt.s.wu 1.000000 is 1.0
fcvt.s.w 1.000000 is 1.0
fcvt.s.lu 1.000000 is 1.0
fcvt.s.l 1.000000 is 1.0
fcvt.s.d 1.000000 is 1.0
```

### `RVV1.0`

使用`PLCT-LLVM`编译器

下载

```
$ git clone https://github.com/isrc-cas/rvv-llvm.git
```

构建

```
$ cd rvv-llvm
$ mkdir build
$ cd build
$ cmake -DLLVM_TARGETS_TO_BUILD="X86;RISCV" -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_INSTALL_PREFIX=./install -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
```
生成的可执行文件目录在`./install`

下载测试代码仓库

```
$ git clone -b rvv-1.0 https://github.com/RALC88/riscv-vectorized-benchmark-suite.git
```

进入目录

```
$ cd riscv-vectorized-benchmark-suite/_axpy
```

修改 `Makefile`

```
$ vim Makefile
$ cat Makefile
#makefile
GCC_TOOLCHAIN_DIR := /home/ardxwe/PLCT/Bin/riscv64/
SYSROOT_DIR := $(GCC_TOOLCHAIN_DIR)/riscv64-unknown-elf

LLVM := /home/ardxwe/PLCT/Src/rvv-llvm/build/install/
SPIKE := spike
PK := pk

target = bin/rvv-test

serial:
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR)  -c -o src/axpy.o src/axpy.c
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR) -c -o src/main.o src/main.c
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf  -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR) -c -o src/utils.o src/utils.c
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR)  -O2 -o $(target) src/*.o -lm

vector:
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf -DUSE_RISCV_VECTOR  -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR)  -c -o src/utils.o src/utils.c
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf -DUSE_RISCV_VECTOR -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR)  -c -o src/axpy.o src/axpy.c
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf -DUSE_RISCV_VECTOR  -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR) -c -o src/main.o src/main.c
	${LLVM}/bin/clang  -Wall --target=riscv64-unknown-elf -DUSE_RISCV_VECTOR -march=rv64gcv1p0 -menable-experimental-extensions -O2  --sysroot=$(SYSROOT_DIR) --gcc-toolchain=$(GCC_TOOLCHAIN_DIR) -o $(target) src/*.o -lm  
	
runspike :
	$(SPIKE) --isa=rv64gcv $(PK) $(target) 256
```

注意
 - `GCC_TOOLCHAIN_DIR`  `SYSROOT_DIR` 和 `LLVM` 应该改为本机目录，使用普通版本的工具链即可
 - 不要修改其他

编译
```
$ make vector
```
可执行文件会生成在`./bin`目录

使用 此分支的`QEMU`可执行文件运行测试

```
$ /home/ardxwe/PLCT/Src/plct-qemu/build/qemu-riscv64 -cpu plct-u64,x-v=true /home/ardxwe/PLCT/Src/riscv-vectorized-benchmark-suite/_axpy/bin/rvv-test
init_vector time: 0.000530
doing reference axpy
axpy_reference time: 0.000201
doing vector axpy
axpy_intrinsics time: 0.016320
done
Result ok !!!
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