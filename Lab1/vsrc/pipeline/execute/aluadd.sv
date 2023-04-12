`ifndef __ALUADD_SV
`define __ALUADD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module aluadd
	import common::*;
	import pipes::*;
(
	input word_t imm, pc,
	output word_t addsumpc
);
	word_t simm = {imm[62:0],1'b0};
	assign addsumpc = simm + pc;

	
endmodule

`endif
