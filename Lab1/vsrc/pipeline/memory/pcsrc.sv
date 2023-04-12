`ifndef __PCSRC_SV
`define __PCSRC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module pcsrc 
    import common::*;
    import pipes::*;
(
    input word_t addsumpc,
    input word_t result,
    input u1     ALUtoPC,
    input u1     Branch,
    input u1     zero,
    output word_t alu_pc,
    output u1    PCSrc
);

always_comb begin
    if(ALUtoPC)begin
        PCSrc = '1;
        alu_pc = result;
    end else if(Branch & zero)begin
        PCSrc = '1;
        alu_pc = addsumpc;
    end else begin
        PCSrc = '0;
        alu_pc = addsumpc;//中立值
    end
    
end
    
endmodule

`endif