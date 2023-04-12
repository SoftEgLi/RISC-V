`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/memory/pcsrc.sv"
`include "pipeline/memory/readdata.sv"
`include "pipeline/memory/writedata.sv"

`else

`endif 

module memory
    import common::*;
    import pipes::*;
(
    input word_t _Mrd2_selected,
    input word_t _srcM,
    input execute_data_t dataE,
    output memory_data_t dataM_nxt,
    output u1   PCSrc,
    output word_t alu_pc,
    output word_t srcM,
    output word_t Mrd2_selected,
    output strobe_t strobe
);
    readdata readdata(
        ._rd(_srcM),
        .addr(dataE.result[2:0]),
        .msize(dataE.msize),
        .mem_unsigned(dataE.mem_unsigned),
        .rd(srcM)
    );
    writedata writedata(
        ._wd(_Mrd2_selected),
        .addr(dataE.result[2:0]),
        .msize(dataE.msize),
        .wd(Mrd2_selected),
        .strobe(strobe)
    );
    pcsrc pcsrc(
        .addsumpc(dataE.addsumpc),
        .result(dataE.result),
        .ALUtoPC(dataE.ctl.ALUtoPC),
        .Branch(dataE.ctl.Branch),
        .zero(dataE.zero),
        .alu_pc(alu_pc),
        .PCSrc(PCSrc)
    );
    assign dataM_nxt.srcM = srcM;
    assign dataM_nxt.ctl = dataE.ctl;
    assign dataM_nxt.dst = dataE.dst;
    assign dataM_nxt.result = dataE.result;
    assign dataM_nxt.pc = dataE.pc;
    assign dataM_nxt.stat = dataE.stat;
endmodule
`endif