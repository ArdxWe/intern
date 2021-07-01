import os

TEST_DIR = os.path.join(os.getenv("HOME"), "plct-machine")

def get_cmd_output(cmd):
    res = ""
    r = os.popen(cmd)
    info = r.readlines()
    for line in info:
        res += line
    return res

def get_file(path):
    res = ""
    with open(path,'r') as f:
        lines=f.readlines()
        for line in lines:
            res += line
    return res


# for Zfinx

qemu_64 = os.path.join(TEST_DIR, "plct-qemu/build-64/qemu-riscv64")
qemu_32 = os.path.join(TEST_DIR, "plct-qemu/build-32/qemu-riscv32")

zfinx_path = [os.path.join(TEST_DIR, "intern/plct-machine/test/zfinx/zfinx_fp64.elf"), os.path.join(TEST_DIR, "intern/plct-machine/test/zfinx/zfinx_dp64.elf"),
              os.path.join(TEST_DIR, "intern/plct-machine/test/zfinx/zdinx_fp64.elf"), os.path.join(TEST_DIR, "intern/plct-machine/test/zfinx/zdinx_dp64.elf")]

expect_path = ["./zfinx_fp64.txt", "./zfinx_dp64.txt", "./zdinx_fp64.txt", "./zdinx_dp64.txt"]

def for_zfinx(qemu, zfinx_path, sixtyfour_flag, zfinx_flag, expect):
    if sixtyfour_flag:
        bit = "64"
    else:
        bit = "32"
    if zfinx_flag:
        option = "Zfinx=true "
    else:
        option = "Zdinx=true "
    
    cmd = qemu + " -cpu plct-u" + bit + "," + option + zfinx_path
    print("cmd   : " + cmd)
    result = get_cmd_output(cmd)
    if result == expect:
        output = "ok"
    else:
        output = "error"
    print("result: " + option + "qemu-riscv" + bit + " " + os.path.basename(zfinx_path) + "------> " + output)

for_zfinx(qemu_64, zfinx_path[0], True, True, get_file(expect_path[0]))
for_zfinx(qemu_64, zfinx_path[1], True, True, get_file(expect_path[1]))

for_zfinx(qemu_64, zfinx_path[0], True, False, get_file(expect_path[0]))
for_zfinx(qemu_64, zfinx_path[1], True, False, get_file(expect_path[1]))
for_zfinx(qemu_64, zfinx_path[2], True, False, get_file(expect_path[0]))
for_zfinx(qemu_64, zfinx_path[3], True, False, get_file(expect_path[1]))
