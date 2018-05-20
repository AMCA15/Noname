/*
* ALU Module - TestBench
* Anderson Contreras
*/


#include <iostream>

#include "Vdecoder.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"


#define LUI           0b0110111
#define AUIPC         0b0010111
#define JAL           0b1101111
#define JALR          0b1100111
#define BRANCH        0b1100011
#define LOAD          0b0000011
#define STORE         0b0100011
#define OP_IMM        0b0010011
#define OP            0b0110011
#define MISC_MEM      0b0001111
#define SYSTEM        0b1110011

#define INSTRUCTION   0
#define FUNCT3        3
#define IMM_OP        4
#define RS1           5
#define RS2           6
#define RD            7
#define SEL_DAT_A     8
#define SEL_DAT_B     9
#define IS_LUI        10
#define IS_AUIPC      11
#define IS_JAL        12
#define IS_JALR       13
#define IS_BRANCH     14
#define IS_MEM        15
#define WE_MEM        16
#define IS_MISC_MEM   17
#define IS_SYSTEM     18
#define IS_ALU_ALT_OP 19

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

#define TOTAL_TESTS -1


using namespace std;

class SIMULATIONTB: public Testbench<Vdecoder> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      // Test data
      // instruction|is_lui|is_auipc|is_jal|is_jalr|is_branch|is_mem|we_mem|op_imm|op|misc_mem|system
      // alu_op|imm_signed|rs1|rs2|rd
//      int data[TOTAL_TESTS][18] = {}


      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
//        m_core->instruction_i = data[num_test][INSTRUCTION];
        

        Tick();

/*        if(m_core->is_lui_o != data[num_test][IS_LUI] | m_core->is_auipc_o != data[num_test][IS_AUIPC] |
           m_core->is_jal_o != data[num_test][IS_JAL] | m_core->is_jalr_o != data[num_test][IS_JALR] |
           m_core->is_branch_o != data[num_test][IS_BRANCH] | m_core->is_mem_o != data[num_test][IS_MEM] |
           m_core->we_mem_o != data[num_test][WE_MEM] | m_core->is_op_imm_o != data[num_test][IS_OP_IMM] | m_core->is_op_o != data[num_test][IS_OP] |
           m_core->is_misc_mem_o != data[num_test][IS_MISC_MEM] | m_core->is_system_o != data[num_test][IS_SYSTEM] |
           m_core->alu_op_o != data[num_test][ALU_OP] | m_core->imm_signed_o != data[num_test][IMM_SIGNED] |
           m_core->rs1_o != data[num_test][RS1] | m_core->rs2_o != data[num_test][RS2] |
           m_core->rd_o != data[num_test][RD])*/
          return num_test;
      }
    }
};


int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("decoder.vcd");

  int ret = tb->Simulate();

  printf("\nDecoder Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
