/*
* CSR - TestBench
* MANUEL HURTADO
*/


#include <iostream>

#include "Vcsr.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"



#define TOTAL_TESTS 12


using namespace std;

class SIMULATIONTB: public Testbench<Vcsr> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      
      //int data[TOTAL_TESTS][5] = {};

      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {

   
   
        Tick();
        
        //if()
        //  return num_test;
        
      }
    }
 };


int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("csr.vcd");

  int ret = tb->Simulate();

  printf("\nCSR Testbench:\n");

  if(ret == 6)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
