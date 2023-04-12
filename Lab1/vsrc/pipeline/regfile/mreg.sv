`ifndef __MREG_SV
`define __MREG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module mreg 
    import common::*;
    import pipes::*;
(
    input logic clk, reset,
    input execute_data_t dataE_nxt,
    input logic enable,stall,flush,
    output execute_data_t dataE
);
    always_ff @(posedge clk) begin
        if (reset | flush) begin // flush overrides enable
            dataE <= '0;
        end else if (enable) begin
            dataE <= dataE_nxt;
        end else if(stall)begin
            dataE <= dataE;
        end
    end
endmodule
`endif