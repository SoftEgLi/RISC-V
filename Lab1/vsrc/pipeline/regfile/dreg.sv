`ifndef __DREG_SV
`define __DREG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif


module dreg 
    import common::*;
    import pipes::*;
(
    input logic clk, reset,
    input fetch_data_t dataF_nxt,
    input u64 pc,
    input logic enable, stall,flush,
    output fetch_data_t dataF
);
    always_ff @(posedge clk) begin
        if (reset | flush) begin // flush overrides enable
            dataF <= '0;
        end else if (enable) begin
            dataF.raw_instr <= dataF_nxt.raw_instr;
            dataF.pc <= pc;
        end else if(stall)begin
            dataF <= dataF;
        end
    end
endmodule

`endif