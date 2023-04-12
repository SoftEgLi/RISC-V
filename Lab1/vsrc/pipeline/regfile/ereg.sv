`ifndef __EREG_SV
`define __EREG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module ereg 
    import common::*;
    import pipes::*;
(
    input logic clk, reset,
    input decode_data_t dataD_nxt,
    input logic enable,stall,flush,
    output decode_data_t dataD
);
    always_ff @(posedge clk) begin
        if (reset | flush) begin // flush overrides enable
            dataD <= '0;
        end else if (enable) begin
            dataD <= dataD_nxt;
        end else if(stall)begin
            dataD <= dataD;
        end
    end
endmodule
`endif