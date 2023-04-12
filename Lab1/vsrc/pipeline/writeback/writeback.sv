`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module writeback
    import common::*;
    import pipes::*;
(
    input memory_data_t dataM,
    output creg_addr_t wa,
    output word_t wd
);
    always_comb begin
        if(dataM.ctl.MemtoReg)begin
            wd = dataM.srcM;
        end else if (dataM.ctl.PCReg)begin
            wd = dataM.pc + 4;
        end else begin
            wd = dataM.result;
        end
        wa = dataM.dst;
    end
endmodule

`endif