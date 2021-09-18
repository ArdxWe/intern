# use debug flags


## debug flags

```c++
// src/cpu/minor/execute.cc
DPRINTF(CpuVectorIssue,"The Vector Engine could not accept"
                    "the instruction : %s \n",*inst);
```

We could use `--debug-flags=CpuVectorIssue` to get the corresponding output information(like `printf`) from stdout.

Run command I used(build details you could read [readme](https://github.com/RALC88/gem5/blob/develop/src/cpu/vector_engine/README.md)):
```
$ /home/ardxwe/plct/plct-gem5/build/RISCV/gem5.opt --debug-flags=CpuVectorIssue /home/ardxwe/plct/plct-gem5/configs/example/riscv_vector_engine.py --cmd="/home/ardxwe/github/riscv-vectorized-benchmark-suite/_blackscholes/bin/blackscholes_vector.exe 1 /home/ardxwe/github/riscv-vectorized-benchmark-suite/_blackscholes/input/in_256.input output_vector.txt" > output
```

The author provides many kinds of debug flags:

- CpuVectorIssue
- MinorExecute
- VectorEngineInterface
- VectorEngineInfo
- MemUnitReadTiming
- VectorMemUnit
- MemUnitWriteTiming
- InstQueue
- Datapath
- VectorLane
- VectorValidBit
- VectorRegister
- VectorRename
- ReorderBuffer

One flag corresponds to one entry.


## debug one instruction

pc: 0x1036c
instruction: vle_v(load from memory)
```
...
2269227500: system.cpu.execute: Vector Instruction Issue to exec:0/21604.306810/784580/2623046.2623046 pc: 0x1036c (vle_v) 
2269230000: system.cpu.execute: Sending vector isnt to the Vector Engine: 0/21604.306810/784580/2623046.2623046 pc: 0x1036c (vle_v) , pc: 0x   1036C
2269230000: system.cpu.execute: The instruction has been hosted by the Vector Engine 0/21604.306810/784580/2623046.2623046 pc: 0x1036c (vle_v) 
2269230500: system.cpu.execute: Can commit, completed inst: 0/21604.306810/784580/2623046.2623046 pc: 0x1036c (vle_v)
...
```

For each dynamic DPRINTF execution, three things are printed to stdout.

- The current tick when the DPRINTF is executed
- The name of the SimObject that called DPRINTF. This name is usually the Python variable name from the Python config file. However, the name is whatever the SimObject name() function returns. 
- You see whatever format string you passed to the DPRINTF function.

one instruction lifetime:

issue:

``` c++
// 2269227500: system.cpu.execute: Vector Instruction Issue to exec:0/21604.306810/784580/2623046.2623046 pc: 0x1036c (vle_v)
else {
                DPRINTF(CpuVectorIssue,"Vector Instruction Issue to exec:"
                    "%s \n",*inst);
                scoreboard[thread_id].markupInstDests(inst, cpu.curCycle() +
                    Cycles(0), cpu.getContext(thread_id), true);

                QueuedInst fu_inst(inst);
                thread.inFlightInsts->push(fu_inst);
                issued = true;
            } 
```

request grant to VectorEngineInterface.
```c++
// src/cpu/minor/execute.cc
if (!cpu.ve_interface->requestGrant(vector_insn))
                {
                    DPRINTF(CpuVectorIssue,"The Vector Engine could not accept"
                    "the instruction : %s \n",*inst);
                    completed_inst = false;
                } else {
                    ...

                    DPRINTF(CpuVectorIssue,"Sending vector isnt to the Vector"
                        " Engine: %s , pc: 0x%8X\n",*inst , pc);

                    completed_inst = false;
                    completed_vec_inst = false;
                    waiting_vector_engine_resp = true;

                    cpu.ve_interface->sendCommand(vector_insn,xc,src1,src2,
                        [this,inst,vector_insn]() mutable {
                        DPRINTF(CpuVectorIssue,"The instruction has been "
                        "hosted by the Vector Engine %s \n",*inst );
                        completed_vec_inst = true;
                    });
                }
// src/cpu/vector_engine/vector_engine_interface.cc
// we use new command: /home/ardxwe/plct/plct-gem5/build/RISCV/gem5.opt --debug-flags=VectorEngineInterface /home/ardxwe/plct/plct-gem5/configs/example/riscv_vector_engine.py --cmd="/home/ardxwe/github/riscv-vectorized-benchmark-suite/_blackscholes/bin/blackscholes_vector.exe 1 /home/ardxwe/github/riscv-vectorized-benchmark-suite/_blackscholes/input/in_256.input output_vector.txt" > VectorEngineInterface

// 2292275000: system.cpu.ve_interface: Resquesting a grant with answer : 1
bool
VectorEngineInterface::requestGrant(RiscvISA::VectorStaticInst* vinst)
{
    bool grant = vector_engine->requestGrant(vinst);
    DPRINTF(VectorEngineInterface,"Resquesting a grant with answer : %d\n",grant);
    return grant;
}
```

commit, send to vector engine:

```c++
// 2269230000: system.cpu.execute: Sending vector isnt to the Vector Engine: 0/21604.306810/784580/2623046.2623046 pc: 0x1036c (vle_v) , pc: 0x   1036C
DPRINTF(CpuVectorIssue,"Sending vector isnt to the Vector"
                        " Engine: %s , pc: 0x%8X\n",*inst , pc);

                    completed_inst = false;
                    completed_vec_inst = false;
                    waiting_vector_engine_resp = true;

                    cpu.ve_interface->sendCommand(vector_insn,xc,src1,src2,
                        [this,inst,vector_insn]() mutable {
                        DPRINTF(CpuVectorIssue,"The instruction has been "
                        "hosted by the Vector Engine %s \n",*inst );
                        completed_vec_inst = true;
                    });
```

send command to vector engine interface:

```c++
// 2292275000: system.cpu.ve_interface: Sending a new command to the vector engine
void
VectorEngineInterface::sendCommand(RiscvISA::VectorStaticInst* vinst ,ExecContextPtr& xc ,
        uint64_t src1, uint64_t src2,
        std::function<void()> done_callback)
{
    DPRINTF(VectorEngineInterface,"Sending a new command to the vector engine\n");
    vector_engine->dispatch(*vinst,xc,src1,src2,done_callback);
}
```

set reorder buffer:

```c++
// 2269230000: system.cpu.ve_interface.vector_engine.vector_rob: Setting the ROB entry 0  with an old dst 3 

vector_inst_queue->Memory_Queue.push_back(
            new InstQueue::QueueEntry(insn,vector_dyn_insn,xc,
                NULL,src1,src2,last_vtype,last_vl));

ReorderBuffer::set_rob_entry(uint32_t old_dst, bool valid_old_dst)
{
    assert(valid_elements < ROB_Size);

    rob[tail]->old_dst = old_dst;
    rob[tail]->valid_old_dst = valid_old_dst;
    rob[tail]->executed = 0;
    uint32_t return_tail = tail;
    if (valid_old_dst) {
        DPRINTF(ReorderBuffer,"Setting the ROB entry %d  with an old dst %d \n"
            ,tail,old_dst);
    } else {
        DPRINTF(ReorderBuffer,"Setting the ROB entry %d without old dst %d \n"
            ,tail);
    }

    if (tail == ROB_Size-1) {
        tail=0;
    } else {
        tail++;
    }

    valid_elements ++;

    return return_tail;
}
```

```c++
// 2269230000: system.cpu.ve_interface.vector_engine: inst: vle_v v3       PC 0x1036C
printMemInst(insn,vector_dyn_insn);

void
VectorEngine::printMemInst(RiscvISA::VectorStaticInst& insn,VectorDynInst *vector_dyn_insn)
{
    uint64_t pc = insn.getPC();
    bool indexed = (insn.mop() ==3);

    uint32_t PDst = vector_dyn_insn->get_renamed_dst();
    uint32_t POldDst = vector_dyn_insn->get_renamed_old_dst();
    uint32_t Pvs2 = vector_dyn_insn->get_renamed_src2();
    uint32_t Pvs3 = vector_dyn_insn->get_renamed_src3();
    uint32_t PMask = vector_dyn_insn->get_renamed_mask();

    std::stringstream mask_ren;
    if (masked_op) {
        mask_ren << "v" << PMask << ".m";
    } else {
        mask_ren << "";
    }

    if (insn.isLoad())
    {
        if (indexed){
            DPRINTF(VectorInst,"inst: %s v%d v%d       PC 0x%X\n",
                insn.getName(),insn.vd(),insn.vs2(),*(uint64_t*)&pc);
            DPRINTF(VectorRename,"renamed inst: %s v%d v%d %s  old_dst v%d"
                "      PC 0x%X\n",insn.getName(),PDst,Pvs2,mask_ren.str(),POldDst,
                *(uint64_t*)&pc);
        } else {
            DPRINTF(VectorInst,"inst: %s v%d       PC 0x%X\n"
                ,insn.getName(),insn.vd(),*(uint64_t*)&pc);
            DPRINTF(VectorRename,"renamed inst: %s v%d %s  old_dst v%d     "
                " PC 0x%X\n",insn.getName(),PDst,mask_ren.str(),POldDst,*(uint64_t*)&pc);
        }
    }
    else if (insn.isStore())
    {
         if (indexed){
            DPRINTF(VectorInst,"inst: %s v%d v%d       PC 0x%X\n",
                insn.getName(),insn.vd(),insn.vs2(),*(uint64_t*)&pc);
            DPRINTF(VectorRename,"renamed inst: %s v%d v%d %s     PC 0x%X\n",
                insn.getName(),Pvs3,Pvs2,mask_ren.str(),*(uint64_t*)&pc);
        } else {
            DPRINTF(VectorInst,"inst: %s v%d       PC 0x%X\n",
                insn.getName(),insn.vd(),*(uint64_t*)&pc );
            DPRINTF(VectorRename,"renamed inst: %s v%d %s       PC 0x%X\n",
                insn.getName(),Pvs3,mask_ren.str(),*(uint64_t*)&pc);
        }
        
    } else {
        panic("Invalid Vector Instruction insn=%#h\n", insn.machInst);
    }
}
```

