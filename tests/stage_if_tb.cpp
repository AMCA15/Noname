/*
* Instruction Fetch Stage - TestBench
* Anderson Contreras
*/

#include <iostream>

#include "VStage_IF.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"

using namespace std;

class SIMULATIONTB: public Testbench<VStage_IF> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      bool ok = true;
      int exit_code;

      int verify_data = 0;

      for (; getTime() < max_time;) {
        Tick();
  
        verify_data += 4;

        if(m_core->out != verify_data)
          ok = false;     
      }
      if(ok)
        exit_code = 0;
      else
        exit_code = 1;
        
      return exit_code;
    }
};

int main(int argc, char **argv, char **env) {

  double frequency = 1e6;
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB(frequency));

  tb->OpenTrace("Stage_IF.vcd");

  int ret = tb->Simulate(100e3);

  printf("\nStage IF Testbench:\n");

  if(!ret)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed!");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed!");

  printf("\n");

  exit(0);
}
