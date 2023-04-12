`ifndef __CORE_SV
`define __CORE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/regfile/regfile.sv"
`include "pipeline/fetch/fetch.sv"
`include "pipeline/fetch/pcselect.sv"
`include "pipeline/decode/decode.sv"

`include "pipeline/regfile/dreg.sv"
`include "pipeline/regfile/ereg.sv"
`include "pipeline/regfile/mreg.sv"
`include "pipeline/regfile/wreg.sv"
`include "pipeline/regfile/sreg.sv"


`include "pipeline/execute/execute.sv"
`include "pipeline/memory/memory.sv"
`include "pipeline/writeback/writeback.sv"
`include "pipeline/forward/fwt.sv"





`else

`endif

module core 
	import common::*;
	import pipes::*;(
	input logic clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp
	,input logic trint, swint, exint
);
	/* TODO: Add your pipeline here. */
	u64 pc,pc_nxt;
	u1 stallpc;
	creg_addr_t wa;
	word_t wd;
	word_t alu_pc;
	u1 PCSrc;
	fwt_t fwt;
	u1 ld_aluBubble;
	u1 flushW;
	u1 enableW;
	pcselect pcselect (
		.alu_pc(alu_pc),
		.PCSrc(PCSrc),
		.pcplus4(pc + 4),
		.pc_selected(pc_nxt)
	);

	assign ireq.valid = 1'b1;		
	assign ireq.addr = pc;
	u1 stallF;
	assign stallF = (ireq.valid & ~iresp.data_ok) | (dreq.valid & ~dresp.data_ok) | ld_aluBubble;
	always_ff @( posedge clk ) begin		//F阶段流水线寄存器
		if(reset) begin
			pc <= 64'h8000_0000;
		end else if(stallF) begin
			pc <= pc;
		end else begin
			pc <= pc_nxt;
			// pc <= 'b1111;
		end
		
	end


	//fetch阶段
	u32 raw_instr;

	assign raw_instr = iresp.data;

	fetch_data_t dataF, dataF_nxt;
	decode_data_t dataD, dataD_nxt;
	execute_data_t dataE, dataE_nxt;
	memory_data_t dataM, dataM_nxt;
	save_data_t dataS;

	
	
	fetch fetch (					
		.dataF(dataF_nxt),			//输出包装后的指令
		.raw_instr(raw_instr)	//输入指令	
	);
	u1 flushD;
	u1 enableD;
	u1 stallD;
	assign flushD = (ireq.valid & ~iresp.data_ok & ~dreq.valid)|(ireq.valid & ~iresp.data_ok & dresp.data_ok) | PCSrc;
	assign stallD = dreq.valid & ~dresp.data_ok | ld_aluBubble;
	assign enableD = ~(flushD | reset | stallD);

	dreg dreg(
		.clk,.reset,
		.enable(enableD),
		.flush(flushD),
		.stall(stallD),
		.pc(pc),
		.dataF_nxt(dataF_nxt),
		.dataF(dataF)
	);
	
	
	//Decode
	word_t rd1, rd2;		//寄存器数据
	decode decode (
		.Mpcplus4(dataE.pc + 4),
		.wd(wd),
		.Mresult(dataE.result),
		.Dforward1(fwt.Dforward1),
		.Dforward2(fwt.Dforward2),
		.dataF(dataF),
		.rd1(rd1),.rd2(rd2),
		.dataD_nxt(dataD_nxt)
	);
	
	
	regfile regfile(
		.clk, .reset,
		.ra1(dataF.raw_instr[19:15]),
		.ra2(dataF.raw_instr[24:20]),
		.rd1(rd1),
		.rd2(rd2),
		.wvalid(dataM.ctl.RegWrite),
		.wa(wa),
		.wd(wd)
	);
	u1 flushE;
	u1 enableE;
	u1 stallE;
	assign flushE = PCSrc;
	assign stallE = (dreq.valid & ~dresp.data_ok) | ld_aluBubble;
	assign enableE = ~(stallE | reset | flushE);
	ereg ereg(
		.clk,.reset,
		.enable(enableE),
		.flush(flushE),
		.stall(stallE),
		.dataD_nxt(dataD_nxt),
		.dataD(dataD)
	);

	//Execute

	execute execute(
		.Swd(dataS.wd),
		.Mpcplus4(dataE.pc + 4),
		.Mresult(dataE.result),
		.wd(wd),
		.Eforward1(fwt.Eforward1),
		.Eforward2(fwt.Eforward2),
		.dataD(dataD),
		.dataE_nxt(dataE_nxt)
	);
	u1 flushM;
	u1 enableM;
	u1 stallM;
	assign stallM = (dreq.valid & ~dresp.data_ok) | (PCSrc & ireq.valid & ~iresp.data_ok);
	assign enableM = ~(stallM | reset | flushM);
	assign flushM = (PCSrc & ~ireq.valid) | (PCSrc & iresp.data_ok) | (ld_aluBubble & enableW);
	mreg mreg(
		.clk,.reset,
		.flush(flushM),
		.stall(stallM),
		.enable(enableM),
		.dataE(dataE),
		.dataE_nxt(dataE_nxt)
	);

	//Memory
	word_t _srcM,srcM;
	strobe_t strobe;
	assign _srcM = dresp.data;
	assign dreq.addr = {dataE.result};
	word_t _Mrd2_selected,Mrd2_selected;
	always_comb begin		//Memory阶段rd2和Writeback阶段wd之间的转发
		if(fwt.Mforward2 == Wd)begin
			_Mrd2_selected = wd;
		end else begin
			_Mrd2_selected = dataE.rd2;
		end
		
	end
	always_comb begin	
		if(dataE.ctl.MemRead)begin		
			dreq.valid = '1;
			dreq.strobe = '0;
		end else if(dataE.ctl.MemWrite)begin
			dreq.valid = '1;
			dreq.data = Mrd2_selected;
			dreq.strobe = strobe;
		end else begin
			dreq.valid = '0;
		end
	end
	memory memory(
		._Mrd2_selected(_Mrd2_selected),
		.Mrd2_selected(Mrd2_selected),
		._srcM(_srcM),
		.srcM(srcM),
		.dataE(dataE),
		.dataM_nxt(dataM_nxt),
		.PCSrc(PCSrc),
		.alu_pc(alu_pc),
		.strobe(strobe)
	);
	
	assign flushW = (dreq.valid & ~dresp.data_ok) | (PCSrc & ireq.valid & ~iresp.data_ok);
	assign enableW = ~(flushW | reset);
	wreg wreg(
		.clk,.reset,
		.flush(flushW),
		.enable(enableW),
		.dataM_nxt(dataM_nxt),
		.dataM(dataM)
	);

	//writeback

	writeback writeback(
		.dataM(dataM),
		.wa(wa),
		.wd(wd)
	);
	u1 flushS,stallS,enableS;
	assign flushS = dataS.hasValue & (~flushW);
	assign stallS = dataS.hasValue & flushW;
	assign enableS = dataM.ctl.MemRead & dataM.ctl.RegWrite 
					&(((wa == dataD.ra1) & (dataE.dst == dataD.ra2)) | ((wa == dataD.ra2) & (dataE.dst == dataD.ra1)))
					& dataE.ctl.MemRead & dataE.ctl.RegWrite & (dataD.ctl.ALUSrc == 0); 
	sreg sreg(
		.clk,.reset,
		.flush(flushS),
		.stall(stallS),
		.enable(enableS),
		.wd(wd),
		.wa(wa),
		.dataS(dataS)
	);
	fwt forwardUnit(
		.Dra1(dataF.raw_instr[19:15]),
		.Dra2(dataF.raw_instr[24:20]),
		.Era1(dataD.ra1),
		.Era2(dataD.ra2),
		.Wdst(dataM.dst),
		.Mdst(dataE.dst),
		.Mra2(dataE.ra2),
		.Swa(dataS.wa),
		.WRegWrite(dataM.ctl.RegWrite),
		.MRegWrite(dataE.ctl.RegWrite),
		.WStat(dataM.stat),
		.MStat(dataE.stat),
		.MPCReg(dataE.ctl.PCReg),
		.ShasValue(dataS.hasValue),
		.fwt(fwt)
	);
	assign ld_aluBubble = dataE.ctl.MemRead & dataE.ctl.RegWrite & (dataD.ra1 == dataE.dst | dataD.ra2 == dataE.dst);
	u1 device_io;
	assign device_io = dreq.valid && (dreq.addr[31] == 0);



`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (dataM.stat),
		.pc                 (dataM.pc),
		.instr              (0),
		.skip               ((dataM.ctl.MemWrite | dataM.ctl.MemRead) & dataM.result[31] == 0 ),
		// .skip				(dreq.valid & (dreq.addr[31]==0) & (dreq.strobe !=8'h00)),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataM.ctl.RegWrite),
		.wdest              ({3'b0, wa}),
		.wdata              (wd)
	);
	      
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);
	      
	DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);
	      
	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0 /* mstatus & 64'h800000030001e000 */),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	      );
	      
	DifftestArchFpRegState DifftestArchFpRegState(
		.clock              (clk),
		.coreid             (0),
		.fpr_0              (0),
		.fpr_1              (0),
		.fpr_2              (0),
		.fpr_3              (0),
		.fpr_4              (0),
		.fpr_5              (0),
		.fpr_6              (0),
		.fpr_7              (0),
		.fpr_8              (0),
		.fpr_9              (0),
		.fpr_10             (0),
		.fpr_11             (0),
		.fpr_12             (0),
		.fpr_13             (0),
		.fpr_14             (0),
		.fpr_15             (0),
		.fpr_16             (0),
		.fpr_17             (0),
		.fpr_18             (0),
		.fpr_19             (0),
		.fpr_20             (0),
		.fpr_21             (0),
		.fpr_22             (0),
		.fpr_23             (0),
		.fpr_24             (0),
		.fpr_25             (0),
		.fpr_26             (0),
		.fpr_27             (0),
		.fpr_28             (0),
		.fpr_29             (0),
		.fpr_30             (0),
		.fpr_31             (0)
	);
	
`endif
endmodule
`endif