# RISC-V Vector extension in GEM5(V0.7.1)

## 获取修改

```
$ git clone -b develop git@github.com:RALC88/gem5.git
$ cd gem5
$ git reset 1339a1b0801431
```

最新: 60c0e02f7d9c1e42c95173e5f9373a56df234c98

基于: 1339a1b08014311d4fd443d9a26b632a2438d7f7

可以得到81个修改的文件，这是作者的所有修改

## 相关资料

- `easy`: [官方文档`learning GEM5`章节](https://www.gem5.org/documentation/learning_gem5/part2/helloobject/), 详细介绍了如何修改和扩展GEM5，对理解代码最重要！！！

- `hard`: [A RISC-V Simulator and Benchmark Suite for Designing
and Evaluating Vector Architectures](https://dl.acm.org/doi/pdf/10.1145/3422667), 作者关于实现和测试的论文，重要但难度很高

- `hard`: [riscv-v-spec-V-0.7.1](https://github.com/riscv/riscv-v-spec/releases/tag/0.7.1),指令集文档

## SimpleObject(理解代码的核心概念)

gem5 中的几乎所有对象都继承自 `SimObject`

创建一个 `SimObject` 需要四个文件

- VectorEngineInterface.py
- vector_engine_interface.hh
- vector_engine_interface.cc
- SConscript

创建一个SimObject需要五个步骤

1. VectorEngineInterface.py

- SimObject关联的python class
- param后跟类型，可以是简单类型，也可以是复杂类型，例如定义在别处的Simobject，这里的`VectorEngine`即如此
```py
# src/cpu/vector_engine/VectorEngineInterface.py
class VectorEngineInterface(SimObject):
    type = 'VectorEngineInterface' # the C++ class that you are wrapping with this Python SimObject.
    cxx_header = "cpu/vector_engine/vector_engine_interface.hh" # the file that contains the declaration of the class used as the type parameter.

    vector_engine = Param.VectorEngine("RISC-V Vector Engine") # parameter of your SimObject that can be controlled from the Python configuration files
```

2. vector_engine_interface.hh

SimObject声明

- 继承自 C++ SimObject class
- 继承到了许多非纯虚函数，仅需实现构造函数
- 所有的SimObject构造函数都只有一个参数，基于python的SimObject类自动构建
```C++
class VectorEngineInterface : public SimObject
{
public:
    VectorEngineInterface(VectorEngineInterfaceParams *p);
    ~VectorEngineInterface();

private:
    VectorEngine *vector_engine;
};
#endif // __CPU_VECTOR_ENGINE_INTERFACE_HH__
```

3. vector_engine_interface.cc

SimObject实现

- 通过构造函数参数可获取python class中的参数，从而赋值到类成员
- 调用父类构造

```C++
VectorEngineInterface::VectorEngineInterface(VectorEngineInterfaceParams *p) :
SimObject(p),vector_engine(p->vector_engine)
{
}

VectorEngineInterface *
VectorEngineInterfaceParams::create()
{
    return new VectorEngineInterface(this);
}
```

```C++
Foo(const FooParams &) // If the constructor of your SimObject follows the following signature，then a FooParams::create() method will be automatically defined. The purpose of the create() method is to call the SimObject constructor and return an instance of the SimObject
```

4. SConscript

注册

```python
Import('*')

SimObject('VectorEngineInterface.py')

Source('vector_engine_interface.cc')
```

5. riscv_vector_engine.py

配置脚本

`作者的实现可以认为是从riscv_vector_engine.py文件读取配置，通过面向对象里的组合和继承手法，创建一系列的SimObject，层层嵌套，最上层暴露接口，也就是我们作为例子的VectorEngineInterface，结合已有代码，去执行V指令`

```python
system.cpu.ve_interface = VectorEngineInterface(
    vector_engine = VectorEngine(
        vector_rf_ports = vector_rf_ports,
        vector_config = VectorConfig(
            max_vl = options.max_vl
        ),
        vector_reg = VectorRegister(
            lanes_per_access = options.v_lanes/options.num_clusters,
            size = (options.renamed_regs * options.max_vl)/8,
            lineSize =options.VRF_line_size
                        *(options.v_lanes/options.num_clusters),
            numPorts = vector_rf_ports,
            accessLatency = 1
        ),
        vector_inst_queue = InstQueue(
            OoO_queues=options.OoO_queues,
            vector_mem_queue_size = options.mem_queue_size,
            vector_arith_queue_size = options.arith_queue_size
        ),
        vector_rename = VectorRename(
            PhysicalRegs = options.renamed_regs
        ),
        vector_rob = ReorderBuffer(
            ROB_Size = options.rob_size
        ),
        vector_reg_validbit = VectorValidBit(
            PhysicalRegs = options.renamed_regs
        ),
        vector_memory_unit = VectorMemUnit(
            memReader = MemUnitReadTiming(
                channel = (((options.num_clusters-1)*5)+5 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize = options.VRF_line_size
                               * (options.v_lanes/options.num_clusters)
            ),
            memWriter = MemUnitWriteTiming(
                channel = (((options.num_clusters-1)*5)+6 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize = options.VRF_line_size
                               * (options.v_lanes/options.num_clusters)
            ),
            memReader_addr = MemUnitReadTiming(
                channel = (((options.num_clusters-1)*5)+7 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize = options.VRF_line_size
                               * (options.v_lanes/options.num_clusters)
            )
        ),
        num_clusters = options.num_clusters,
        num_lanes = options.v_lanes,
        vector_lane = [VectorLane(
            lane_id = lane_id,
            srcAReader = MemUnitReadTiming(
                channel = ((lane_id*5)+0 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize =  options.VRF_line_size
                                * (options.v_lanes/options.num_clusters)
            ),
            srcBReader = MemUnitReadTiming(
                channel = ((lane_id*5)+1 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize = options.VRF_line_size
                        * (options.v_lanes/options.num_clusters)
            ),
            srcMReader = MemUnitReadTiming(
                channel = ((lane_id*5)+2 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize =  options.VRF_line_size
                                * (options.v_lanes/options.num_clusters)
            ),
            dstReader = MemUnitReadTiming(
                channel = ((lane_id*5)+3 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize =  options.VRF_line_size
                                * (options.v_lanes/options.num_clusters)
            ),
            dstWriter = MemUnitWriteTiming(
                channel = ((lane_id*5)+4 if multiport else 0),
                cacheLineSize = options.cache_line_size,
                VRF_LineSize =  options.VRF_line_size
                                * (options.v_lanes/options.num_clusters)
            ),
            dataPath = Datapath(
                VectorLanes = (options.v_lanes/options.num_clusters),
                clk_domain = SrcClockDomain(
                    clock = options.vector_clk,
                    voltage_domain = VoltageDomain()
                )
            )
        )for lane_id in range(0,options.num_clusters)]
    )
)
...
m5.instantiate()

print("Beginning simulation!")
exit_event = m5.simulate()
print('Exiting @ tick %i because %s' % (m5.curTick(), exit_event.getCause()))
print("gem5 finished %s" % datetime.datetime.now().strftime("%b %e %Y %X"))
```

实际的每一个SimObject都有更多的参数和方法来实现功能

## 工作流程

从外部理解:
execute.cc
- 在commit阶段判断如果是V指令，调用`requestGrant`发送指令给vector engine,尝试获得允许
- 调用`sendCommand`向vector engine 发送命令

vector engine 内部:

vector_engine_interface.hh

- 向 `execute.cc`暴露三个接口: requestGrant, sendCommand, reqAppVectorLength(配置指令)
- 一个`VectorEngine`指针，进行实际vector engine 的操作

vector_engine.hh

- requestGrant: 进行实际操作，判断寄存器个数是否满足需求等
- dispatch: `sendCommand`接口的实际行为,rename, 分配到临时队列，等待条件满足调用`issue`，执行指令。

## 核心部分

### Vector Renaming

vector_engine.hh

- 写寄存器逻辑寄存器与物理寄存器可能不同
- 空闲寄存器链表 FRL(Free Register List) 存储可用寄存器
- 寄存器映射表 RAT(Register Alias Table) 存储逻辑寄存器与物理寄存器映射 类似于(page table)

### Reorder Buffer(ROB)

- 允许指令按序提交
- 一个ROB对应一条指令，存储指令相关信息
- 指令相应队列存储ROB地址，可以修改ROB内部信息

## 存在的问题

- 具体实现细节
- 理解论文内容
- V-spec的理解
