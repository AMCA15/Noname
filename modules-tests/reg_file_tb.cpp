/*
* Register File Module - TestBench
* Anderson Contreras
*/


#include <iostream>

#include "Vreg_file.h"
#include "testbench_modules.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"


#define RS1    0
#define RS2    1
#define RD     2
#define RF_WD  3
#define WE     4
#define RS1_D  5
#define RS2_D  6

#define TOTAL_TESTS 12


using namespace std;

class SIMULATIONTB: public Testbench<Vreg_file> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      // Test data    [rs1 | rs2 | rd | rf_wd | we | rs1_d | rs2_d]
      int data[TOTAL_TESTS][7] = {
        { 0,   1,  2, 200, 0,   0,   0},
        { 8,   3,  2, 200, 1,   0,   0},
        { 1,   2,  1, 500, 1, 500, 200},
        { 5,   4,  3,  18, 1,   0,   0},
        { 1,   2,  4, 300, 1, 500, 200},
        { 0,   3,  0,  32, 1,   0,  18},
        { 3,   0,  6,  64, 0,  18,   0},
        { 31, 31, 31, 128, 1, 128, 128},
        { 5,   5,  5, 256, 0,   0,   0},
        { 5,   5,  5, 999, 1, 999, 999},
        { 4,   3,  4, 100, 0, 300,  18},
        { 5,   6,  5, 150, 1, 150,   0}};


      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->rs1_i    = data[num_test][RS1];
        m_core->rs2_i    = data[num_test][RS2];
        m_core->rd_i     = data[num_test][RD] ;
        m_core->rf_wd_i  = data[num_test][RF_WD] ;
        m_core->we_i     = data[num_test][WE] ;

        Tick();

        if((m_core->rs1_d_o != data[num_test][RS1_D]) || (m_core->rs2_d_o != data[num_test][RS2_D]))
          return num_test;
      }
    }
};


int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("reg_file.vcd");

  int ret = tb->Simulate();

  printf("\nRegister File Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
