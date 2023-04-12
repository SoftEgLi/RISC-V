`ifndef __MULT2_SV
`define __MULT2_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module mult2 
    import common::*;
    import pipes::*;
#(
    parameter bit_length = 64
) 
    
(
    input logic signal,
    input logic[bit_length-1:0] a,b,
    output logic[bit_length-1:0] y
);
    always_comb begin
        if(signal)begin
            y = b;
        end else begin
            y = a;
        end
        
    end
endmodule

`endif