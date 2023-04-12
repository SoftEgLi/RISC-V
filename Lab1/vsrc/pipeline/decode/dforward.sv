`ifndef __DFORWARD_SV
`define __DFORWARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module dforward 
    import common::*;
    import pipes::*;
(
    input word_t rd,wd,Mresult,Mpcplus4,
    input forward_t signal,
    output word_t y
);
    always_comb begin
        if(signal == Wd)begin
            y = wd;
        end else if(signal == Result)begin
            y = Mresult;
        end else if(signal == PCplus4)begin
            y = Mpcplus4;
        end else y = rd;
        
    end
    
endmodule

`endif