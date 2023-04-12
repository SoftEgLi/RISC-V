`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module pcselect 
    import common::*;
    import pipes::*;(

    input u64 pcplus4,
    input u64 alu_pc,
    input u1 PCSrc,
    output u64 pc_selected
    
);
always_comb begin
    if(PCSrc)begin
        pc_selected = alu_pc;
    end else begin
        pc_selected = pcplus4;
    end
    
end



endmodule


`endif
