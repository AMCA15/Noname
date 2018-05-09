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


#define TOTAL_TESTS 16


using namespace std;

class SIMULATIONTB: public Testbench<VALU> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      // Test data
      int data[TOTAL_TESTS][4] = {
        {          5,     6,   ALU_ADD,         11},    // 5 + 6 = 11
        {        -20,     5,   ALU_ADD,        -15},    // -20 + 5 = -15
        {       -187,   187,   ALU_ADD,          0},    // -187 + 187 = 0
        {          4,     3,   ALU_SUB,          1},    // 4 - 3 = 1
        {        -23,  -127,   ALU_SUB,        104},    // -23 - (-127) = 104
        {        245,   120,   ALU_AND,        112},    // 245 & 120 = 112
        {        100,    50,   ALU_OR,         118},    // 100 | 50 = 118
        {        573,   215,   ALU_XOR,        746},    // 573 ^ 215 = 746
        {       1024,     3,   ALU_SRL,        128},    // 1024 >> 4 = 128
        {-2147483648,     5,   ALU_SRL,   67108864},    // -2147483648 >> 5 = 67108864
        {-2147483648,     5,   ALU_SRA,  -67108864},    // -2147483648 >> 5 = -67108864
        {         64,     5,   ALU_SLL,       2048},    // 64 << 5 = 2048
        {          1,    10,   ALU_SLT,          1},    // 1 < 10 = true
        {         20,    10,   ALU_SLT,          0},    // 20 < 10 = false
        {         10,     0,   ALU_SLTU,         1},    // 10 != 0 = true
        {          0,     0,   ALU_SLTU,         0}};   // 0 != 0 = false


      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->in0 = data[num_test][IN0];
        m_core->in1 = data[num_test][IN1];
        m_core->op  = data[num_test][OP] ;

        Tick();

        if(m_core->out != data[num_test][OUT])
          return num_test;
      }
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
