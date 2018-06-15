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

// Opcodes
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

// Data tests
#define INSTRUCTION   0
#define FUNCT3        1
#define RS1           2
#define RS2           3
#define RD            4
#define IMM_OP        5
#define SEL_DAT_A     6
#define SEL_DAT_B     7
#define ALU_OP        8
#define CSR_ADDR      9
#define IS_LUI        10
#define IS_AUIPC      11
#define IS_JAL        12
#define IS_JALR       13
#define IS_BRANCH     14
#define IS_MEM        15
#define WE_MEM        16
#define IS_MISC_MEM   17
#define IS_SYSTEM     18
#define E_ILLEGAL     19

// ALU Operations
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

// Imm-Gen Operations
#define IMM_I  0b000
#define IMM_S  0b001
#define IMM_B  0b010
#define IMM_U  0b011
#define IMM_J  0b100
#define IMM_C  0b101


// Mux control for ALU's inputs
#define SEL_REG  0b00
#define SEL_IMM  0b01
#define SEL_PC   0b10
#define SEL_ZERO 0b11


#define TOTAL_TESTS 18


using namespace std;

class SIMULATIONTB: public Testbench<Vdecoder> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      // Test data
      // instruction | funct3 | rs1 | rs2 | rd | imm_op | sel_dat_a | sel_dat_b | alu_op | csr_addr
      // is_lui | is_auipc | is_jal | is_jalr | is_branch | is_mem | we_mem | misc_mem | system | e_illegal
      long long int data[TOTAL_TESTS][20] = {
        
        // TODO: Fill the data tests
        {0x00001f17, 1, 0, 30, IMM_U, SEL_PC, SEL_IMM, ALU_ADD, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // auipc	t5,0x1
        {0x03ff0663, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // beq	t5,t6,40
        {0xfe0f0f13, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // addi	t5,t5,-32
        {0x000f0067, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // jr	t5
        {0x5391e193, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // ori	gp,gp,1337
        {0x80000eb7, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // lui	t4,0x80000
        {0x30529073, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // csrw	mtvec,t0
        {0x45df1a63, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // bne	t5,t4,5dc
        {0xfc3f2023, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // sw	gp,-64(t5)
        {0x30405073, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // csrwi	mie,0
        {0x00054863, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // bltz	a0,c0
        {0x00000073, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // ecall
        {0x0000dead, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // INVALID INSTRUCTION
        {0x30200073, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // mret ??????
        {0x00208f33, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // add	t5,ra,sp
        {0x0ff0000f, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // fence
        {0x00119193, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},   // slli	gp,gp,0x1
        {0x34202f73, 0, 0,  0,     0,       0,      0,       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};  // csrr	t5,mcause


      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->instruction_i = data[num_test][INSTRUCTION];
        

        Tick();

        if(m_core->funct3_o != data[num_test][FUNCT3] | m_core->rd_o != data[num_test][RD] |
           m_core->rs1_o != data[num_test][RS1] | m_core->rs2_o != data[num_test][RS2] |
           m_core->imm_op_o != data[num_test][IMM_OP] | m_core->alu_op_o != data[num_test][OP] |
           m_core->sel_dat_a_o != data[num_test][SEL_DAT_A] | m_core->sel_dat_b_o != data[num_test][SEL_DAT_B] |
           m_core->csr_addr_o != data[num_test][CSR_ADDR] | m_core->is_lui_o != data[num_test][IS_LUI] |
           m_core->is_auipc_o != data[num_test][IS_AUIPC] | m_core->is_jal_o != data[num_test][IS_JAL] |
           m_core->is_jalr_o != data[num_test][IS_JALR] | m_core->is_branch_o != data[num_test][IS_BRANCH] |
           m_core->is_mem_o != data[num_test][IS_MEM] | m_core->we_mem_o != data[num_test][WE_MEM] | 
           m_core->is_misc_mem_o != data[num_test][IS_MISC_MEM] | m_core->is_system_o != data[num_test][IS_SYSTEM] |
           m_core->e_illegal_inst_o != data[num_test][E_ILLEGAL])
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
