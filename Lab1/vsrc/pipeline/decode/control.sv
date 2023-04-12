`ifndef __CONTROL_SV
`define __CONTROL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module control 
    import common::*;
    import pipes::*;
(
    input logic[6:0] opcode,
    output control_t ctl,
    output u1 stat
);
    always_comb begin
        ctl = '0;
        stat = '1;
        unique case(opcode)
            Rtype:begin
                ctl.op = ROp;
                ctl.RegWrite = '1;
            end
            IALUtype:begin
                ctl.op = IALUOp;
                ctl.RegWrite = '1;
                ctl.ALUSrc = '1;
            end
            ILOADtype:begin
                ctl.op = ILOADOp;
                ctl.RegWrite = '1;
                ctl.ALUSrc = '1;
                ctl.MemRead = '1;
                ctl.MemtoReg = '1;
            end
            Uluitype:begin
                ctl.op = UluiOp;
                ctl.RegWrite = '1;
                ctl.ALUSrc = '1;
            end
            Uauipctype:begin
                ctl.op = UauipcOp;
                ctl.RegWrite = '1;
                ctl.ALUPc = '1;
                ctl.ALUSrc = '1;
            end
            Jjaltype:begin
                ctl.op = JjalOp;
                ctl.RegWrite = '1;
                ctl.ALUSrc = '1;
                ctl.PCReg = '1;
                ctl.Branch = '1;
            end
            Btype:begin
                ctl.op = BOp;
                ctl.Branch = '1; 
            end
            Stype:begin
                ctl.op = SOp;
                ctl.ALUSrc = '1;
                ctl.MemWrite = '1;
            end
            Ijalrtype:begin
                ctl.op = IjalrOp;
                ctl.RegWrite = '1;
                ctl.ALUSrc = '1;
                ctl.PCReg = '1;
                ctl.ALUtoPC = '1;
            end
            IWtype:begin
                ctl.op = IWOp;
                ctl.RegWrite = '1;
                ctl.ALUSrc = '1;
            end
            ALUWtype:begin
                ctl.op = ALUWOp;
                ctl.RegWrite = '1;
            end
            default:begin
                stat = '0;
            end

            

            

        endcase

        
    end
    
endmodule



`endif