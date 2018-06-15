/*
* Instruction Decode Stage - TestBench
* Anderson Contreras
*/

#include <iostream>

#include "Vstage_id.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"

// Input
#define INSTRUCTION     0
#define PC              1
#define RD_I            2
#define RF_WD           3
#define RF_WE           4
#define IS_FWD_A        5
#define IS_FWD_B        6
#define DAT_FWD_A       7
#define DAT_FWD_B       8

// Output 
#define FUNCT3          0
#define RD_O            1
#define ALU_OP          2
#define CSR_ADDR        3
#define DAT_A           4
#define DAT_B           5
#define IS_LUI          6
#define IS_AUIPC        7
#define IS_JAL          8
#define IS_JALR         9
#define IS_BRANCH       10
#define IS_MEM          11
#define WE_MEM          12
#define IS_MISC_MEM     13
#define IS_SYSTEM       14
#define E_ILLEGAL_INST  15

#define TOTAL_TESTS 1

using namespace std;

class SIMULATIONTB: public Testbench<Vstage_id> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();


      // Test input data
      // [ Instruction | PC | RD_I | RF_WD | RF_WE | is_fwd_a | is_fwd_b | dat_fwd_a | dat_fwd_b ]
      int unsigned data_i[TOTAL_TESTS][9] = {
        { 0x00000000, 0x00000000, 0, 0, 0, 0, 0, 0, 0 }};

      // Test output data
      // [ Funct3 | RD_O | ALU OP | CSR addr | data | datb | lui | auipc | jal | jalr | br | mem | we_mem | misc | sys | exc ]
      int unsigned data_o[TOTAL_TESTS][16] = {
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};
      
      
      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->instruction_i = data_i[num_test][INSTRUCTION];
        m_core->pc_i          = data_i[num_test][PC];
        m_core->rd_i          = data_i[num_test][RD_I];
        m_core->rf_wd_i       = data_i[num_test][RF_WD];
        m_core->rf_we_i       = data_i[num_test][RF_WE];
        m_core->is_fwd_a_i    = data_i[num_test][IS_FWD_A];
        m_core->is_fwd_b_i    = data_i[num_test][IS_FWD_B];
        m_core->dat_fwd_a_i   = data_i[num_test][DAT_FWD_A];
        m_core->dat_fwd_b_i   = data_i[num_test][DAT_FWD_B];

        Tick();

        if ((m_core->funct3_o != data_o[num_test][FUNCT3])       || (m_core->rd_o != data_o[num_test][RD_O]) ||
            (m_core->alu_op_o != data_o[num_test][ALU_OP])       || (m_core->csr_addr_o != data_o[num_test][CSR_ADDR]) ||
            (m_core->dat_a_o != data_o[num_test][DAT_A])         || (m_core->dat_b_o != data_o[num_test][DAT_B]) ||
            (m_core->is_lui_o != data_o[num_test][DAT_B])        || (m_core->is_auipc_o != data_o[num_test][IS_AUIPC]) ||
            (m_core->is_jal_o != data_o[num_test][IS_JAL])       || (m_core->is_jalr_o != data_o[num_test][IS_JALR]) ||
            (m_core->is_branch_o != data_o[num_test][IS_JALR])   || (m_core->is_mem_o != data_o[num_test][IS_MEM]) ||
            (m_core->we_mem_o != data_o[num_test][WE_MEM])       || (m_core->is_misc_mem_o != data_o[num_test][IS_MISC_MEM]) ||
            (m_core->is_system_o != data_o[num_test][IS_SYSTEM]) || (m_core->e_illegal_inst_o != data_o[num_test][E_ILLEGAL_INST]));
          return num_test;
      }
    }
};

int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("stage_id.vcd");

  int ret = tb->Simulate();

  printf("\nStage ID Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
