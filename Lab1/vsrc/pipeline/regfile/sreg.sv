`ifndef __SREG_SV
`define __SREG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module sreg
    import common::*;
    import pipes::*;
(
    input logic clk, reset, 
    input word_t wd,
    input creg_addr_t wa,
    input logic enable,flush,stall,
    output save_data_t dataS
);
always_ff @(posedge clk) begin
    if(reset | flush)begin
        dataS <= 'b0;
    end else if(stall)begin
        dataS <= dataS;
    end else if(enable)begin
        dataS.wd <= wd;
        dataS.wa <= wa;
        dataS.hasValue <= 'b1;
    end
end
endmodule

`endif