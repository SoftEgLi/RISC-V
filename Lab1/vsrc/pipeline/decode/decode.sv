`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/control.sv"
`include "pipeline/decode/alucontrol.sv"
`include "pipeline/decode/immGen.sv"
`include "pipeline/decode/dforward.sv"

`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input fetch_data_t dataF,
    input word_t rd1,rd2,
    input word_t wd,
    input word_t Mresult,
    input word_t Mpcplus4,
    input forward_t Dforward1,
    input forward_t Dforward2,
    output decode_data_t dataD_nxt
);
    u1 stat_temp1,stat_temp2;
    word_t rd1_selected,rd2_selected;
    control_t ctl;
    word_t imm;
    dforward dforward1(
        .Mpcplus4(Mpcplus4),
        .rd(rd1),
        .wd(wd),
        .Mresult(Mresult),
        .signal(Dforward1),
        .y(rd1_selected)
    );
    dforward dforward2(
        .Mpcplus4(Mpcplus4),
        .rd(rd2),
        .wd(wd),
        .Mresult(Mresult),
        .signal(Dforward2),
        .y(rd2_selected)
    );
    control control(
        .opcode(dataF.raw_instr[6:0]),
        .ctl(ctl),
        .stat(stat_temp1)
    );
    //立即数有符号拓展
    immGen immGen(
        .dataF(dataF),
        .op(ctl.op),
        .imm(imm)
    );
    alucontrol alucontrol(
        .stat(stat_temp2),
        .func3(dataF.raw_instr[14:12]),
        .i30(dataF.raw_instr[30]),
        .i25(dataF.raw_instr[25]),
        .op(ctl.op),
        .alufunc(dataD_nxt.alufunc),
        .msize(dataD_nxt.msize),
        .mem_unsigned(dataD_nxt.mem_unsigned)
    );
    assign dataD_nxt.stat = stat_temp1 & stat_temp2;
    assign dataD_nxt.ctl = ctl;
    assign dataD_nxt.dst = dataF.raw_instr[11:7];
    assign dataD_nxt.rd1 = rd1_selected;
    assign dataD_nxt.rd2 = rd2_selected;
    assign dataD_nxt.ra1 = dataF.raw_instr[19:15];
    assign dataD_nxt.ra2 = dataF.raw_instr[24:20];
    assign dataD_nxt.imm = imm;
    assign dataD_nxt.pc = dataF.pc;

    
endmodule


`endif
