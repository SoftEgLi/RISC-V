`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alu
	import common::*;
	import pipes::*;(
	input word_t srca, srcb,
	input alufunc_t alufunc,
	output word_t result,
	output u1 zero
);
	word_t result_temp;
	always_comb begin
		unique case(alufunc)
			ALU_ADD: begin
				result_temp = srca + srcb;
				zero = '0;
			end
			ALU_SUB: begin
				result_temp = srca - srcb;
				if(result_temp == '0)begin
					zero = '1;
				end else zero = '0;
			end
			ALU_SLL: begin
				result_temp = srca << srcb[5:0];
				zero = '1;
			end
			ALU_SLT: begin
				if($signed(srca)< $signed(srcb))begin
					result_temp = 'b1;
				end	else result_temp = 'b0;
				zero = '0;
			end
			ALU_SLTU:begin
				result_temp = {63'b0,(srca < srcb)};
				zero = '0;
			end
			ALU_XOR :begin
				result_temp = srca ^ srcb;
				zero = '0;
			end
			ALU_SRL :begin
				result_temp = srca >> srcb[5:0];
				zero = '0;
			end
			ALU_SRA :begin
				result_temp = ($signed(srca)) >>> srcb[5:0];
				zero = '0;
			end
			ALU_OR  :begin
				result_temp = srca | srcb;
				zero = '0;
			end
			ALU_AND :begin
				result_temp = srca & srcb;
				zero = '0;
			end
			ALU_LUI :begin
				result_temp = {srcb[63:32],srcb[19:0],12'b0};
				zero = '0;
			end
			ALU_JAL :begin
				result_temp = '0;
				zero = '1;
			end
			ALU_AUIPC:begin
				result_temp = srca + {srcb[51:0],12'b0};
				zero = '0;
			end
			ALU_JALR:begin
				result_temp = (srca + srcb) & (~64'b1);
				zero = '0;
			end
			ALU_BNE:begin
				result_temp = srca - srcb;
				if(result_temp == '0)begin
					zero = '0;
				end else zero = '1;
			end
			ALU_BLT:begin
				result_temp = '0;
				if($signed(srca) < $signed(srcb))begin
					zero = '1;
				end else zero = '0;
			end
			ALU_BGE:begin
				result_temp = '0;
				if($signed(srca) < $signed(srcb))begin
					zero = '0;
				end else zero = '1;
			end
			ALU_BLTU:begin
				result_temp = '0;
				if(srca < srcb)begin
					zero = '1;
				end else zero = '0;
			end
			// ALU_JALR:result_temp = {52'b0,srcb[11:0]};
			ALU_BGEU:begin
				result_temp = '0;
				if(srca < srcb)begin
					zero = '0;
				end else zero = '1;
			end	
			ALU_ADDIW:begin	 //pay attention
				result_temp = srca + srcb;
				result_temp = {{32{result_temp[31]}},result_temp[31:0]};
				zero = '0;
			end
			ALU_SLLIW:begin
				result_temp = srca << srcb[5:0];
				result_temp = {{32{result_temp[31]}},result_temp[31:0]};
				zero = '0;
			end
			ALU_SRLIW:begin
				result_temp[31:0] = srca[31:0] >> srcb[5:0];
				result_temp = {{32{result_temp[31]}},result_temp[31:0]};
				zero = '0;
			end
			ALU_SRAIW:begin
				result_temp = srca;
				result_temp[63:32] = {{32{result_temp[31]}}};
				result_temp = result_temp >>> srcb[4:0];
				result_temp = {{32{result_temp[32]}},result_temp[31:0]};
			end
			ALU_ADDW:begin
				result_temp = srca + srcb;
				result_temp = {{32{result_temp[31]}},result_temp[31:0]};
				zero = '0;
			end
			ALU_SUBW:begin
				result_temp = srca - srcb;
				result_temp = {{32{result_temp[31]}},result_temp[31:0]};
			end
			ALU_SLLW:begin
				result_temp[31:0] = srca[31:0] << srcb[4:0];
				result_temp = {{32{result_temp[31]}},result_temp[31:0]};
			end
			ALU_SRLW:begin
				result_temp[31:0] = srca[31:0] >> srcb[4:0];
				result_temp = {{32{result_temp[31]}},result_temp[31:0]};
				// result_temp = {{32{result_temp[31]}},result_temp[31:0]};
			end
			ALU_SRAW:begin
				result_temp = srca;
				result_temp[63:32] = {{32{result_temp[31]}}};
				result_temp = result_temp >>> srcb[4:0];
				result_temp = {{32{result_temp[32]}},result_temp[31:0]};
			end
			default: begin
				result_temp = {{63{1'b1}},1'b0};
				zero = '0;
			end
		endcase
	end
	assign result = result_temp;
	
endmodule

`endif
