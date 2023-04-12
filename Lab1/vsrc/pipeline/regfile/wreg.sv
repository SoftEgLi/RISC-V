`ifndef __WREG_SV
`define __WREG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module wreg 
    import common::*;
    import pipes::*;
(
    input logic clk, reset,
    input memory_data_t dataM_nxt,
    input logic enable,flush,
    output memory_data_t dataM
);
    always_ff @(posedge clk) begin
        if (reset | flush) begin // flush overrides enable
            dataM <= '0;
        end else if (enable) begin
            dataM <= dataM_nxt;
        end
    end
endmodule
`endif