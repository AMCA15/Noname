/*
* ALU Module - TestBench
* Anderson Contreras
*/


#include <iostream>

#include "Vimm_gen.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"

#define INSTRUCTION   0
#define IMM_OP        1
#define IMM_OUT       2


#define IMM_I    0b000
#define IMM_S    0b001
#define IMM_B    0b010
#define IMM_U    0b011
#define IMM_J    0b100
#define IMM_C    0b101


#define TOTAL_TESTS 7


using namespace std;

class SIMULATIONTB: public Testbench<Vimm_gen> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      // Test data        
      long long int data[TOTAL_TESTS][3] = {       // Instruction | Imm_op | Imm_out
        {0x00700000, IMM_I,          7},    // 0x00700000  |    I   |    7
        {0x3A000000, IMM_I,        928},    // 0x3A000000  |    I   |    928
        {0x6B700000, IMM_I,       1719},     // 0xE5600000  |    I   |   256
        {0x60B0A000, IMM_U,       1622188032},     // 0xE5600000  |    I   |   256
        {0x00001000, IMM_U,       4096},         // 0xE5600000  |    I   |   256
        {0x53B33000, IMM_S,       226618},           // 0xE5600000  |    I   |   256
        {0xE5600000, IMM_S,       -426}};        // 0xE5600000  |    I   |   256

      
      int num_test;

      for (num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->instruction_i = data[num_test][INSTRUCTION];
        m_core->imm_op_i = data[num_test][IMM_OP];

        Tick();

        if(m_core->imm_o != data[num_test][IMM_OUT])
          break;
      }

      return num_test;
    }
};


int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("imm_gen.vcd");

  int ret = tb->Simulate();

  printf("\nImmediate Generator Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
