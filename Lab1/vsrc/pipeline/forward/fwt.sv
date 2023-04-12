`ifndef __FWT_SV
`define __FWT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
// `include "pipeline/memory/pcsrc.sv"
// `include "pipeline/memory/readdata.sv"
// `include "pipeline/memory/writedata.sv"

`else

`endif 

module fwt 
    import common::*;
    import pipes::*;
(
    input creg_addr_t Dra1,
    input creg_addr_t Dra2,
    input creg_addr_t Era1,
    input creg_addr_t Era2,
    input creg_addr_t Wdst,
    input creg_addr_t Mdst,
    input creg_addr_t Mra2,
    input creg_addr_t Swa,
    input logic WRegWrite,
    input logic MRegWrite,
    input logic WStat,
    input logic MStat,
    input logic MPCReg,
    input logic ShasValue,
    output fwt_t fwt
);  
    u1 DMcondition1,DMcondition2;
    u1 DWcondition1,DWcondition2;
    u1 EMcondition1,EMcondition2;
    u1 EWcondition1,EWcondition2;
    u1 MWcondition2;
    u1 EScondition1,EScondition2;
always_comb begin
    fwt = '0;
    DMcondition1 = MStat & MRegWrite & (Mdst !=0) & (Mdst == Dra1);
    DWcondition1 = WStat & WRegWrite & (Wdst !=0) & (~DMcondition1) & (Wdst == Dra1);
    DMcondition2 = MStat & MRegWrite & (Mdst !=0) & (Mdst == Dra2);
    DWcondition2 = WStat & WRegWrite & (Wdst !=0) & (~DMcondition2) &(Wdst == Dra2);
    if(DMcondition1 & (~MPCReg))begin
        fwt.Dforward1 = Result;
    end else if(DMcondition1 & MPCReg)begin
        fwt.Dforward1 = PCplus4;
    end else if(DWcondition1)begin
        fwt.Dforward1 = Wd;
    end else fwt.Dforward1 = Regs;
    if(DMcondition2 & (~MPCReg))begin
        fwt.Dforward2 = Result;
    end else if(DMcondition2 & MPCReg)begin
        fwt.Dforward2 = PCplus4;
    end else if(DWcondition2)begin
        fwt.Dforward2 = Wd;
    end else fwt.Dforward2 = Regs;
    
    EMcondition1 = MStat & MRegWrite & (Mdst !=0) & (Mdst == Era1);
    EMcondition2 = MStat & MRegWrite & (Mdst !=0) & (Mdst == Era2);
    EWcondition1 = WStat & WRegWrite & (Wdst !=0) &  (~EMcondition1) & (Wdst == Era1);
    EWcondition2 = WStat & WRegWrite & (Wdst !=0) &  (~EMcondition2) & (Wdst == Era2);
    EScondition1 = ShasValue & (Swa == Era1);
    EScondition2 = ShasValue & (Swa == Era2);
    if(EMcondition1 & (~MPCReg))begin    //M阶段转发1
        fwt.Eforward1 = Result;
    end else if(EMcondition1 & MPCReg)begin
        fwt.Eforward1 = PCplus4;
    end else if(EWcondition1)begin
        fwt.Eforward1 = Wd;
    end else if(EScondition1)begin
        fwt.Eforward1 = Sregwd;
    end else begin
        fwt.Eforward1 = Regs;
    end
    if(EMcondition2 & (~MPCReg))begin    //M阶段转发2
        fwt.Eforward2 = Result;
    end else if(EMcondition2 & MPCReg)begin
        fwt.Eforward2 = PCplus4;
    end else if(EWcondition2)begin
        fwt.Eforward2 = Wd;
    end else if(EScondition2)begin
        fwt.Eforward2 = Sregwd;
    end else begin
        fwt.Eforward2 = Regs;
    end
    
    MWcondition2 = WStat & WRegWrite & (Wdst !=0) & (Mra2 == Wdst);
    if(MWcondition2)begin    //W阶段转发给M阶段，解决ld，sd冲突
        fwt.Mforward2 = Wd;
    end else fwt.Mforward2 = Regs;
     
end
endmodule

`endif