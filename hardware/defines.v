/*
* Defines
* Anderson Contreras
*/

`define NOP               32'h33

//----------------------   MEM/WB  ------------------------------

`define R_MEM_DATA_O      335:304
`define R_E_LD_ADDR_MIS   303
`define R_E_ST_ADDR_MIS   302

//----------------------   EXE/MEM  -----------------------------

`define R_E_INST_ADDR_MIS 301
`define R_ALU_OUT         300:269


//----------------------   ID/EXE  ------------------------------
`define R_FUNCT3          268:266
`define R_RS1             265:261
`define R_RS2             260:256
`define R_RD              255:251
`define R_RS1_DAT         250:219
`define R_RS2_DAT         218:187
`define R_ALU_OP          186:183
`define R_CSR_ADDR        182:171
`define R_DAT_A           170:139
`define R_DAT_B           138:107
`define R_IMM_OUT         106:75
`define R_IS_OP           74
`define R_IS_LUI          73
`define R_IS_AUIPC        72
`define R_IS_JAL          71
`define R_IS_JALR         70
`define R_IS_BRANCH       69
`define R_IS_LD_MEM       68
`define R_IS_ST_MEM       67
`define R_IS_MISC_MEM     66
`define R_IS_SYSTEM       65
`define R_E_ILLEGAL_INST  64

//----------------------   IF/ID   ------------------------------
`define R_PC              63:32
`define R_INSTRUCTION     31:0

