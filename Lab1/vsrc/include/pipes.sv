`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;
/* Define instrucion decoding rules here */

// parameter F7_RI = 7'bxxxxxxx;

/* Define pipeline structures here */

typedef struct packed {
	u32 raw_instr;
	u64 pc;
} fetch_data_t;

typedef enum logic [3:0] { 
	ROp,IALUOp,ILOADOp,IjalrOp,UluiOp,UauipcOp,JjalOp,BOp,SOp,IWOp,ALUWOp
} decode_op_t; 

typedef enum logic [2:0] { 
	Regs,Result,Wd,PCplus4,Sregwd
} forward_t;

typedef struct packed {
	forward_t Eforward1;//处理ALU数据依赖
	forward_t Eforward2;//处理ALU数据依赖
	forward_t Mforward2; //处理ld和sd冲突
	forward_t Dforward1;
	forward_t Dforward2;
} fwt_t;

typedef enum logic [5:0] {
	ALU_ADD,ALU_SUB,ALU_SLL,ALU_SLT,ALU_SLTU,ALU_XOR,ALU_SRL,ALU_SRA,ALU_OR,ALU_AND,
	ALU_LUI,ALU_JAL,ALU_AUIPC,ALU_JALR,ALU_BNE,ALU_BLT,ALU_BGE,ALU_BLTU,ALU_BGEU,
	ALU_ADDIW,ALU_SLLIW,ALU_SRLIW,ALU_SRAIW,
	ALU_ADDW,ALU_SUBW,ALU_SLLW,ALU_SRLW,ALU_SRAW
} alufunc_t;

typedef struct packed {
	decode_op_t op;
	u1 Branch;
	u1 RegWrite;
	u1 MemRead;
	u1 MemWrite;
	u1 MemtoReg;
	u1 ALUSrc;	//有效，srcb的值为立即数，无效：srcb = rd2;
	u1 ALUPc;	//有效：srca的值为PC，无效：srca=rd1;
	u1 PCReg;	//PC+4值给寄存器
	u1 ALUtoPC;	//ALU计算结果传给PC，不需要Branch和Zero控制
} control_t;

typedef struct packed {
	word_t rd1, rd2;
	control_t ctl;
	creg_addr_t dst; 
	creg_addr_t ra1,ra2;
	word_t imm;
	word_t pc;
	alufunc_t alufunc;
	u1 stat;
	msize_t msize;
	u1 mem_unsigned;
} decode_data_t;			//original

typedef struct packed {
	word_t result;
	word_t rd2;
	creg_addr_t ra2;
	control_t ctl;
	creg_addr_t dst;
	u1 zero;
	word_t addsumpc;
	u64 pc;
	u1 stat;
	msize_t msize;
	u1 mem_unsigned;
} execute_data_t;

typedef struct packed {
	word_t srcM;
	word_t result;
	control_t ctl;
	creg_addr_t dst;
	u64 pc;
	u1 stat;
} memory_data_t;

typedef struct packed {
	word_t wd;
	creg_addr_t wa;
	u1 hasValue;
} save_data_t;
parameter Rtype = 7'b0110011;
parameter IALUtype = 7'b0010011;
parameter ILOADtype = 7'b0000011;
parameter Ijalrtype = 7'b1100111;
parameter Uluitype = 7'b0110111;
parameter Uauipctype = 7'b0010111;
parameter Jjaltype = 7'b1101111;
parameter Btype = 7'b1100011;
parameter Stype = 7'b0100011;
parameter IWtype = 7'b0011011;	
parameter ALUWtype = 7'b0111011;	
endpackage

`endif
