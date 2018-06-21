/*
* Instruction Fetch Stage - TestBench
* Anderson Contreras
*/

#include <iostream>

#include "Vstage_if.h"
#include "testbench.h"
#include "wbmemory.h"
#include "colors.h"

#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"


// Use short names for the core signals
#define wbm_addr_o m_core->wbm_addr_o
#define wbm_dat_o  m_core->wbm_dat_o
#define wbm_sel_o  m_core->wbm_sel_o
#define wbm_cyc_o  m_core->wbm_cyc_o
#define wbm_stb_o  m_core->wbm_stb_o
#define wbm_we_o   m_core->wbm_we_o
#define wbm_dat_i  m_core->wbm_dat_i
#define wbm_ack_i  m_core->wbm_ack_i
#define wbm_err_i  m_core->wbm_err_i
#define wbm_re_i   m_core->wbm_re_i

// Define parameters for RAM
#define MEMSTART 0x00000000u    // Initial address
#define MEMSZ    0x00080000u    // size: 512 KB


#define SEL_ADDR        0
#define STALL           1
#define BRANCH_ADDR     2
#define EXCEPT_ADDR     3
#define OUTPUT          4

#define SEL_ADDR_PC4    0
#define SEL_ADDR_BR     1
#define SEL_ADDR_EXC    2
#define STALL_ON        1
#define STALL_OFF       0

#define TOTAL_TESTS 15

using namespace std;

class SIMULATIONTB: public Testbench<Vstage_if> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(const std::string &progfile, unsigned long max_time=1000000){
      // Create memory
      const std::unique_ptr<WBMEMORY> memory_ptr(new WBMEMORY(MEMSTART, MEMSZ >> 2));
      WBMEMORY &memory = *memory_ptr;
      memory.Load(progfile);
      Reset();

      // Test data   [Addr_Src | Stall | Branch Address | Exception Address | Output]
      int unsigned data[TOTAL_TESTS][5] = {                    //                              PC     | STALL | INSTRUCTION
        {SEL_ADDR_PC4, STALL_OFF, 0x00004000, 0xF0F0F0F0, 0x04C0006F},  // PC = PC + 4   = 0x00000000 |  NO   |  0x04c0006f
        {SEL_ADDR_PC4, STALL_OFF, 0xDEADF00D, 0xF0F0F0F0, 0x34202F73},  // PC = PC + 4   = 0x00000004 |  NO   |  0x34202f73
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 0xCCCCCCCC, 0x34202F73},  // PC = PC       = 0x00000004 |  YES  |  0x34202f73
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 0xCCCCCCCC, 0x34202F73},  // PC = PC       = 0x00000004 |  YES  |  0x34202f73
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 0xCCCCCCCC, 0x34202F73},  // PC = PC       = 0x00000004 |  YES  |  0x34202f73
        {SEL_ADDR_BR,  STALL_OFF, 0x00000040, 0xCCCCCCCC, 0x00001F17},  // PC = BR_ADDR  = 0x00000040 |  NO   |  0x00001f17
        {SEL_ADDR_PC4, STALL_OFF, 0x00050001, 0x00050000, 0xFC3F2023},  // PC = PC + 4   = 0x00000044 |  NO   |  0xfc3f2023
        {SEL_ADDR_PC4, STALL_OFF, 0x00000004, 0x00050000, 0xFF9FF06F},  // PC = PC + 4   = 0x00000048 |  NO   |  0xff9ff06f
        {SEL_ADDR_EXC, STALL_OFF, 0x00000080, 0x0000004C, 0xF1402573},  // PC = EXC_ADDR = 0x0000004C |  NO   |  0xf1402573
        {SEL_ADDR_PC4, STALL_OFF, 0x00000080, 0x00000080, 0x00051063},  // PC = PC + 4   = 0x00000050 |  NO   |  0x00051063
        {SEL_ADDR_PC4, STALL_ON,  0x0000DEAD, 0xDEADDEAD, 0x00051063},  // PC = PC       = 0x00000050 |  YES  |  0x00051063
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 0x00000000, 0x00051063},  // PC = PC       = 0x00000050 |  YES  |  0x00051063
        {SEL_ADDR_PC4, STALL_OFF, 0xABCDEF00, 0xFFFF0000, 0x00000297},  // PC = PC + 4   = 0x00000054 |  NO   |  0x00000297
        {SEL_ADDR_PC4, STALL_ON,  0xABCDEF00, 0x0000FFFF, 0x00000297},  // PC = PC       = 0x00000054 |  YES  |  0x00000297
        {SEL_ADDR_BR,  STALL_OFF, 0x000000FC, 0xFEDCBA00, 0x00000093}}; // PC = PC + 4   = 0x00000093 |  NO   |  0x01028293
      
      for (int num_test = 0; num_test < TOTAL_TESTS;) {
        m_core->br_j_addr_i      = data[num_test][BRANCH_ADDR];
        m_core->sel_addr_i       = data[num_test][SEL_ADDR];
        m_core->stall_i          = data[num_test][STALL];
        m_core->exception_addr_i = data[num_test][EXCEPT_ADDR];
        

        Tick();

        // simulate memory
        memory(wbm_addr_o, wbm_dat_o, wbm_sel_o, wbm_cyc_o, wbm_stb_o, wbm_we_o, wbm_dat_i, wbm_ack_i, wbm_err_i);

        
        if (wbm_ack_i && (!wbm_cyc_o && wbm_ack_i)) {
          if(m_core->instruction_o != data[num_test][OUTPUT])
            return num_test;
          num_test++;
        }
      }
    }
};

int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("stage_if.vcd");

  const std::string &progfile = "debug-tests-extra/rv32ui-p-add.elf";

  int ret = tb->Simulate(progfile);

  printf("\nStage IF Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
