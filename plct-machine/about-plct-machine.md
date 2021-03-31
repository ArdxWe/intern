# plct-machine

## 介绍

`plct-machine` 是基于 `qemu`， `RISCV`的虚拟开发板， 开发者可以在其上跑目前`RISCV`大多数扩展的可执行文件， 省去了寻找不同`qemu`版本运行的麻烦， 一次编译，多种环境运行。


## 特性

支持运行一下扩展的`RISCV`可执行文件:

- [P扩展](https://github.com/romanheros/qemu/tree/packed-upstream-v1)

- [K扩展](https://github.com/isrc-cas/plct-qemu/tree/plct-k-dev)

- [B扩展]()

- [Zfinx扩展](https://github.com/isrc-cas/plct-qemu/tree/plct-zfinx-dev)

- [RVV1.0](https://github.com/sifive/qemu/tree/rvv-1.0-upstream-v7-vfredosum)

## 构建
这意味着我们可以这样使用

64位:
```
$ git checkout new-machine-dev
$ mkdir build
$ cd build
$ ../configure --target-list=riscv64-linux-user,riscv64-softmmu
$ ./qemu-riscv64 -cpu plct-u64 <your elf>
```

32位:

```
$ git checkout new-machine-dev
$ mkdir build
$ cd build
$ ../configure --target-list=riscv32-linux-user,riscv64-softmmu
$ ./qemu-riscv32 -cpu plct-u32 <your elf>
```

## 使用

 针对不同的扩展，我们需要在执行的时候添加一些选项(以64位为例)

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

完整的构建，测试视频看这里[video](https://address.com)


## 联系

- 做其他扩展的开发者，希望有 `plct-machine` 的支持
- 发现存在的 `bug`
- 任何构建，执行的问题

都可以与 `PLCT` 联系

- <wangjunqiang@iscas.ac.cn>
- <ardxwe@gmail.com>