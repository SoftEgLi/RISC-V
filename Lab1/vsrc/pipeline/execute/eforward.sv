`ifndef __EFORWARD_SV
`define __EFORWARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module eforward 
    import common::*;
    import pipes::*;
(
    input word_t result,wd,rd,Mpcplus4,Swd,
    input forward_t signal,
    output word_t y
);
    always_comb begin
        if(signal == Result)begin
            y = result;
        end else if(signal == Wd)begin
            y = wd;
        end else if(signal == PCplus4)begin
            y = Mpcplus4;
        end else if(signal == Sregwd)begin
            y = Swd;
        end else y = rd;
        
    end
    
endmodule

`endif