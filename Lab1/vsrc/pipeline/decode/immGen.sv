`ifndef __IMMGEN_SV
`define __IMMGEN_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module immGen 
    import common::*;
    import pipes::*;
(
    input fetch_data_t dataF,
    input decode_op_t op,
    output word_t imm
);
    always_comb begin
        if(op == IALUOp || op == ILOADOp || op == IjalrOp || op == IWOp)begin
            imm = {{53{dataF.raw_instr[31]}}, dataF.raw_instr[30:20]};

        end else if(op == UluiOp || op == UauipcOp)begin
            imm = {{45{dataF.raw_instr[31]}},dataF.raw_instr[30:12]};   

        end else if(op == JjalOp)begin
            imm = {{45{dataF.raw_instr[31]}},dataF.raw_instr[19:12],dataF.raw_instr[20],dataF.raw_instr[30:21]};
            
        end else if(op == BOp)begin
            imm = {{53{dataF.raw_instr[31]}},dataF.raw_instr[7],dataF.raw_instr[30:25],dataF.raw_instr[11:8]};

        end else if(op == SOp)begin
            imm = {{53{dataF.raw_instr[31]}},dataF.raw_instr[30:25],dataF.raw_instr[11:7]};
        
        end else begin
            imm = '0;
        
        end


    end
endmodule


`endif