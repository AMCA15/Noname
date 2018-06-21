/*
* Execution Stage - TestBench
* Anderson Contreras
*/

#include <iostream>

#include "Vstage_exe.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"


#define PC_I        0
#define IMM_I       1
#define DAT_A       2
#define DAT_B       3
#define ALU_OP      4
#define FUNCT3      5
#define ALU_OUT     6
#define IS_JAL      7
#define IS_JALR     8
#define IS_BRANCH   9
#define BR_J_TAKEN  10
#define BR_J_ADDR   11
#define E_INST_MIS  12

#define ALU_ADD   0b0000
#define ALU_SUB   0b1000
#define ALU_AND   0b0111
#define ALU_OR    0b0110
#define ALU_XOR   0b0100
#define ALU_SRL   0b0101
#define ALU_SLL   0b0001
#define ALU_SRA   0b1101
#define ALU_SLT   0b0010
#define ALU_SLTU  0b0011


#define BEQ 	 0b000
#define BNE 	 0b001
#define BLT 	 0b100
#define BGE 	 0b101
#define BLTU   0b110
#define BGEU   0b111

#define TOTAL_TESTS 15

using namespace std;

class SIMULATIONTB: public Testbench<Vstage_exe> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();


      // Test data
      long long int data[TOTAL_TESTS][13] = {
      // [  PC      |   IMM   |     Data A | Data B | ALU OP | Funct3 | ALU_O | Jl/Jlr/Br | Br_J tkn | Br_J Addr | E inst mis ]                                      //   ALU Operation   | 
        {0x00004000, 0x00000040,       115,    455,  ALU_ADD,   BEQ,     570,   0, 0, 0,       0,           570,       1},
        {0xDEADF00D, 0x00008000,       135,     70,  ALU_SUB,   BNE,      65,   0, 0, 0,       0,            65,       1},
        {0x00000040, 0x00000004,      1124,   1100,  ALU_ADD,   BLT,    2224,   0, 1, 0,       1,          2224,       0},
        {0x00000000, 0x00001000,      2000,   1000,  ALU_ADD,   BGE,    3000,   1, 0, 0,       1,          3000,       0},
        {0x00060000, 0x00000001,   0x60000, 0x4001,  ALU_AND,  BLTU,       0,   0, 0, 1,       0,    0x00060001,       1},
        {0x00040000, 0x00000500,      0x01,   0x20,  ALU_ADD,  BGEU,    0x21,   0, 1, 0,       0,          0x21,       1},
        {0x00050001, 0x0000ABC0,       123,   -123,  ALU_ADD,   BEQ,       0,   0, 0, 0,       0,    0x0000ABC0,       0},
        {0x00000004, 0x00000DE0,    -10045,      0,  ALU_ADD,   BNE,       0,   0, 0, 0,       0,    0x00000DE0,       0},
        {0x00000080, 0x00045007,       195,    195,  ALU_ADD,   BLT,       0,   0, 0, 0,       0,    0x00045007,       0},
        {0x00000080, 0x00E88E00,      1659,   1970,  ALU_ADD,   BGE,       0,   0, 0, 0,       0,    0x00E88E00,       0},
        {0x0000DEAD, 0x00001580,      1127,  -1127,  ALU_ADD,  BLTU,       0,   0, 0, 0,       0,    0x00001580,       0},
        {0x00000000, 0x00010200,       112,    -44,  ALU_ADD,  BGEU,       0,   0, 0, 0,       0,    0x00010200,       0},
        {0xABCDEF00, 0x00223000,       102,      1,  ALU_ADD,     3,       0,   0, 0, 0,       0,    0x00223000,       0},
        {0xABCDEF00, 0x00005008,       124,     -1,  ALU_ADD,     4,       0,   0, 0, 0,       0,    0x00005008,       0},
        {0x00000000, 0x00954FD0,         0,      0,  ALU_ADD,     5,       0,   0, 0, 0,       0,    0x00954FD0,       0}};
      
      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->pc_i           = data[num_test][PC_I];
        m_core->imm_i          = data[num_test][IMM_I];
        m_core->dat_a_i        = data[num_test][DAT_A];
        m_core->dat_b_i        = data[num_test][DAT_B];
        m_core->alu_op_i       = data[num_test][ALU_OP];
        m_core->funct3_i       = data[num_test][FUNCT3];
        m_core->is_jal_inst_i  = data[num_test][IS_JAL];
        m_core->is_jalr_inst_i = data[num_test][IS_JALR];
        m_core->is_br_inst_i   = data[num_test][IS_BRANCH];


        Tick();

        if((m_core->is_br_j_taken_o != data[num_test][BR_J_TAKEN] || 
           (m_core->br_j_addr_o != data[num_test][BR_J_ADDR]) ||
           (m_core->alu_out_o != data[num_test][ALU_OUT] ||
           (m_core->e_inst_addr_mis_o != data[num_test][E_INST_MIS]))))
          return num_test;
      }
    }
};

int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("stage_exe.vcd");

  int ret = tb->Simulate();

  printf("\nStage EXE Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
