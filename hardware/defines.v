/*
* Defines
* Anderson Contreras
*/



//----------------------   MEM/WB  ------------------------------

`define R_MEM_DATA_O      258:227
`define R_E_LD_ADDR_MIS   226
`define R_E_ST_ADDR_MIS   225

//----------------------   EXE/MEM  -----------------------------

`define R_E_INST_ADDR_MIS 224
`define R_ALU_OUT         223:192


//----------------------   ID/EXE  ------------------------------
`define R_FUNCT3          191:189
`define R_RS1             188:184
`define R_RS2             183:179
`define R_RD              178:174
`define R_ALU_OP          173:170
`define R_CSR_ADDR        169:138
`define R_DAT_A           137:106
`define R_DAT_B           105:74
`define R_IS_LUI          73
`define R_IS_AUIPC        72
`define R_IS_JAL          71
`define R_IS_JALR         70
`define R_IS_BRANCH       69
`define R_IS_MEM          68
`define R_WE_MEM          67
`define R_IS_MISC_MEM     66
`define R_IS_SYSTEM       65
`define R_E_ILLEGAL_INST  64

//----------------------   IF/ID   ------------------------------
`define R_INSTRUCTION     63:32
`define R_PC              31:0

