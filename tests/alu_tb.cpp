/*
* ALU Module - TestBench
* Anderson Contreras
*/


#include <iostream>

#include "VALU.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"

#define IN0      0
#define IN1      1
#define OP       2
#define OUT      3

#define TOTAL_TESTS 6

using namespace std;

class SIMULATIONTB: public Testbench<VALU> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      // Test data
      int data[TOTAL_TESTS][4] = {{5, 6, 0, 11},           // 5 + 6 = 11
                                  {4, 3, 1, 1},            // 4 - 3 = 1
                                  {245, 120, 2, 112},      // 245 & 120 = 112
                                  {100, 50, 3, 118},       // 100 | 50 = 118
                                  {1024, 3, 4, 128},       // 1024 >> 4 = 128
                                  {64, 5, 5, 2048}};       // 64 << 5 2048

      int num_test = 0;


      for (; num_test < TOTAL_TESTS; num_test++) {
        m_core->in0 = data[num_test][IN0];
        m_core->in1 = data[num_test][IN1];
        m_core->op  = data[num_test][OP] ;

        Tick();

        if(m_core->out != data[num_test][OUT])
          break; 
      }
      return num_test;
    }
};

int main(int argc, char **argv, char **env) {

  double frequency = 1e6;
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB(frequency));

  tb->OpenTrace("ALU.vcd");

  int ret = tb->Simulate(100e3);

  printf("\nALU Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! Complete: %d/%d", ret, TOTAL_TESTS);
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! Complete: %d/%d", ret, TOTAL_TESTS);

  printf("\n");

  exit(0);
}
