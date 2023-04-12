`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`include "pipeline/execute/mult2.sv"
`include "pipeline/execute/aluadd.sv"
`include "pipeline/execute/eforward.sv"

`else

`endif

module execute
    import common::*;
    import pipes::*;
(
    input word_t Mresult,wd,Mpcplus4,Swd,
    input forward_t Eforward1,Eforward2,
    input decode_data_t dataD,
    output execute_data_t dataE_nxt
);
    word_t rd1_selected,rd2_selected;
    word_t srca,srcb;
    eforward eforward1(
        .Swd(Swd),
        .Mpcplus4(Mpcplus4),
        .result(Mresult),
        .wd(wd),
        .rd(dataD.rd1),
        .signal(Eforward1),
        .y(rd1_selected)
    );
    eforward eforward2(
        .Swd(Swd),
        .Mpcplus4(Mpcplus4),
        .result(Mresult),
        .wd(wd),
        .rd(dataD.rd2),
        .signal(Eforward2),
        .y(rd2_selected)
    );
    mult2 mult2A(
        .a(rd1_selected),
        .b(dataD.pc),
        .signal(dataD.ctl.ALUPc),
        .y(srca)
    );
    mult2 mult2B(
        .a(rd2_selected),
        .b(dataD.imm),
        .signal(dataD.ctl.ALUSrc),
        .y(srcb)
    );
    alu alu(
        .srca(srca),
        .srcb(srcb),
        .alufunc(dataD.alufunc),
        .result(dataE_nxt.result),
        .zero(dataE_nxt.zero)
    );
    aluadd aluadd(
        .imm(dataD.imm),
        .pc(dataD.pc),
        .addsumpc(dataE_nxt.addsumpc)
    );
    assign dataE_nxt.ctl = dataD.ctl;
    assign dataE_nxt.dst = dataD.dst;
    assign dataE_nxt.rd2 = rd2_selected;
    assign dataE_nxt.pc = dataD.pc;
    assign dataE_nxt.stat = dataD.stat;
    assign dataE_nxt.ra2 = dataD.ra2;
    assign dataE_nxt.msize = dataD.msize;
    assign dataE_nxt.mem_unsigned = dataD.mem_unsigned;
endmodule
`endif