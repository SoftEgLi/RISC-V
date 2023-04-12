`ifndef __ALUCONTROL_SV
`define __ALUCONTROL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alucontrol 
    import common::*;
    import pipes::*;
(
    input logic[2:0] func3,
    input logic i30,
    input logic i25,
    input decode_op_t op,
    output alufunc_t alufunc,
    output u1 stat,
    output msize_t msize,
    output u1 mem_unsigned
);  //生成alufunc
    always_comb begin
        stat = '1;
        msize = MSIZE8;
        mem_unsigned = '0;
       if(op == ROp || op == IALUOp)begin
            unique case(func3)
                3'b000:begin
                    if(i30 && op == ROp)alufunc = ALU_SUB;
                    else alufunc = ALU_ADD;
                end
                3'b001:begin
                    alufunc = ALU_SLL;
                end
                3'b010:begin
                    alufunc = ALU_SLT;
                end
                3'b011:begin
                    alufunc = ALU_SLTU;
                end
                3'b100:begin
                    alufunc = ALU_XOR;
                end
                3'b101:begin
                    if(i30 && op == ROp)begin
                        alufunc = ALU_SRA;
                    end else if(i30 && op == IALUOp)begin
                        alufunc = ALU_SRA;
                    end else if(op == ROp)begin
                        alufunc = ALU_SRL;
                    end else begin
                        alufunc = ALU_SRL;
                    end
                end
                3'b110:begin
                    alufunc = ALU_OR;
                end
                3'b111:begin
                    alufunc = ALU_AND;
                end
                default:begin
                    alufunc = ALU_SUB;
                end
            endcase
       end else if(op == UluiOp)begin
            alufunc = ALU_LUI;
       end else if(op == JjalOp)begin
            alufunc = ALU_JAL;
       end else if(op == BOp)begin
            unique case (func3)
                3'b000:begin
                    alufunc = ALU_SUB;
                end 
                3'b001:begin
                    alufunc = ALU_BNE;
                end
                3'b100:begin
                    alufunc = ALU_BLT;
                end
                3'b101:begin
                    alufunc = ALU_BGE;
                end
                3'b110:begin
                    alufunc = ALU_BLTU;
                end
                3'b111:begin
                    alufunc = ALU_BGEU;
                end
                default: begin
                    alufunc = ALU_SUB;
                end
            endcase
       end else if(op == ILOADOp)begin
            unique case (func3)
                3'b011: begin
                    alufunc = ALU_ADD;
                end
                3'b000:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE1;
                    mem_unsigned = '0;
                end
                3'b001:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE2;
                    mem_unsigned = '0;
                end
                3'b010:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE4;
                    mem_unsigned = '0;
                end
                3'b100:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE1;
                    mem_unsigned = '1;
                end
                3'b101:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE2;
                    mem_unsigned = '1;
                end
                3'b110:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE4;
                    mem_unsigned = '1;
                end
                default: begin
                    alufunc = ALU_SUB;
                end
            endcase
       end else if(op == SOp)begin
            unique case (func3)
                3'b011: begin
                    alufunc = ALU_ADD;
                end
                3'b000:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE1;
                end
                3'b001:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE2;
                end
                3'b010:begin
                    alufunc = ALU_ADD;
                    msize = MSIZE4;
                end
                default: begin
                    // alufunc = 5'b11100;
                    alufunc = ALU_ADD;

                end
            endcase
       end else if(op == UauipcOp)begin
            alufunc = ALU_AUIPC;
       end else if(op == IjalrOp)begin
            alufunc = ALU_JALR;
       end else if(op == IWOp)begin
            unique case (func3)
                3'b000:begin
                    alufunc = ALU_ADDIW;
                end
                3'b001:begin
                    alufunc = ALU_SLLIW;
                    if(i25)begin
                        stat = '0;
                    end else stat = '1;
                end
                3'b101:begin
                    if(i30 == 0)begin
                        alufunc = ALU_SRLIW;
                        if(i25)begin
                            stat = '0;
                        end else begin
                            stat = '1;
                        end
                    end else begin
                        alufunc = ALU_SRAIW;
                        if(i25)begin
                            stat = '0;
                        end else begin
                            stat = '1;
                        end
                    end
                end

                default: begin
                    alufunc = ALU_SLL;
                end
            endcase
       end else if(op == ALUWOp)begin
            unique case (func3)
                3'b000:begin
                    if(i30 == '0)begin
                        alufunc = ALU_ADDW;
                    end else begin
                        alufunc = ALU_SUBW;
                    end
                end 
                3'b001:begin
                    alufunc = ALU_SLLW;
                end
                3'b101:begin
                    if(i30)begin
                        alufunc = ALU_SRAW;
                    end else begin
                        alufunc = ALU_SRLW;
                    end
                end
                default: begin
                    alufunc = ALU_SLL;
                end
            endcase
       end else begin 
        alufunc = ALU_LUI;
       end
    end
endmodule


`endif