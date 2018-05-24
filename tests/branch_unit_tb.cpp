/*
* Branch Unit - TestBench
* By Adrián González
*/

#include <iostream>
#include <stdint.h>
#include "Vbranch_unit.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"

#define BRANCH_OP       0
#define EQU_I           1
#define LT_I            2
#define LTU_I           3
#define IS_BRANCH_TAKEN 4

#define TOTAL_TESTS     18

using namespace std;

class SIMULATIONTB: public Testbench<Vbranch_unit> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();


      // Test data   
      int data[TOTAL_TESTS][5] = {
        //[branch_op_i | equ_i | lt_i | ltu_i | is_branch_taken_o]
          {     0      ,   0   ,   0  ,   0   ,         0        }, //BEQ: equ_i=0 => is_branch_taken=0
          {     0      ,   1   ,   0  ,   0   ,         1        }, //BEQ: equ_i=1 => is_branch_taken=1
          {     1      ,   1   ,   0  ,   0   ,         0        }, //BNE: equ_i=1 => is_branch_taken=0
          {     1      ,   0   ,   0  ,   0   ,         1        }, //BNE: equ_i=0 => is_branch_taken=1
          {     2      ,   1   ,   1  ,   1   ,         0        }, //Case not defined => default => is_branch_taken=0
          {     3      ,   1   ,   1  ,   1   ,         0        }, //Case not defined => default => is_branch_taken=0
          {     4      ,   1   ,   0  ,   1   ,         0        }, //BLT: lt_i=0 => is_branch_taken=0
          {     4      ,   1   ,   1  ,   1   ,         1        }, //BLT: lt_i=1 => is_branch_taken=1
          {     5      ,   0   ,   1  ,   1   ,         0        }, //BGE: equ_i=0 lt_i=1 => is_branch_taken=0
          {     5      ,   0   ,   0  ,   0   ,         0        }, //BGE: equ_i=0 lt_i=0 => is_branch_taken=0
          {     5      ,   1   ,   1  ,   1   ,         0        }, //BGE: equ_i=1 lt_i=1 => is_branch_taken=0
          {     5      ,   1   ,   0  ,   0   ,         1        }, //BGE: equ_i=1 lt_i=0 => is_branch_taken=1
          {     6      ,   1   ,   0  ,   0   ,         0        }, //BLTU: ltu_i=0 => is_branch_taken=0
          {     6      ,   1   ,   1  ,   1   ,         1        }, //BLTU: ltu_i=1 => is_branch_taken=1
          {     7      ,   0   ,   0  ,   1   ,         0        }, //BGEU: equ_i=0 ltu_i=1 => is_branch_taken=0
          {     7      ,   0   ,   0  ,   0   ,         0        }, //BGEU: equ_i=0 ltu_i=0 => is_branch_taken=0
          {     7      ,   1   ,   0  ,   1   ,         0        }, //BGEU: equ_i=1 ltu_i=1 => is_branch_taken=0
          {     7      ,   1   ,   0  ,   0   ,         1        }  //BGEU: equ_i=1 ltu_i=0 => is_branch_taken=1
        };
        



      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {

        m_core->branch_op_i = data[num_test][BRANCH_OP];
        m_core->equ_i = data[num_test][EQU_I];
        m_core->lt_i   = data[num_test][LT_I];
        m_core->ltu_i   = data[num_test][LTU_I];
        
        Tick();
        if(m_core->is_branch_taken_o != data[num_test][IS_BRANCH_TAKEN])
          return num_test;
      }
    }
};

int main(int argc, char **argv, char **env) {

  double frequency = 1e6;
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB(frequency));

  tb->OpenTrace("branch_unit.vcd");

  int ret = tb->Simulate(100e3);

  printf("\nBranch Unit Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! Complete: %d/%d", ret, TOTAL_TESTS);
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! Complete: %d/%d", ret, TOTAL_TESTS);

  printf("\n");

  exit(0);
}

