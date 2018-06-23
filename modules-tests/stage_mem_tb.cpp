/*
* Instruction Fetch Stage - TestBench
* Anderson Contreras
*/

#include <iostream>

#include "Vstage_mem.h"
#include "testbench_modules.h"
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
#define MEMSTART 0x80000000u    // Initial address
#define MEMSZ    0x00080000u    // size: 512 KB


#define FUNCT3       0
#define MEM_DATA_I   1
#define MEM_ADDR_I   2
#define MEM_DATA_O   3
#define IS_MEM       4
#define WE_MEM       5

// Values for funct3
#define LB       0b000
#define LH       0b001
#define LW       0b010
#define LBU      0b100
#define LHU      0b101
#define SB       0b000
#define SH       0b001
#define SW       0b010


#define TOTAL_TESTS 8

using namespace std;

class SIMULATIONTB: public Testbench<Vstage_mem> {
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

      // Test data   [ funct3 | mem_data_i | mem_addr_i | mem_data_o | is_mem | we_mem ]
      int unsigned data[TOTAL_TESTS][6] = {
        { LB, 500, 0x80000000, 500, 1, 0},
        { LH, 500, 0x80000004, 500, 1, 0},
        { LW, 500, 0x80000008, 500, 1, 0},
        {LBU, 500, 0x800000A0, 500, 1, 0},
        {LHU, 500, 0x800000B0, 500, 1, 0},
        { SB, 500, 0x800000C0, 500, 0, 1},
        { SH, 500, 0x800000D0, 500, 0, 1},
        { SW, 500, 0x800000E0, 500, 0, 1}};



      for (int num_test = 0; num_test < TOTAL_TESTS;) {
        m_core->is_mem_i   = data[num_test][IS_MEM];
        m_core->we_mem_i   = data[num_test][WE_MEM];
        m_core->funct3_i   = data[num_test][FUNCT3];
        m_core->mem_data_i = data[num_test][MEM_DATA_I];
        m_core->mem_addr_i = data[num_test][MEM_ADDR_I];
        

        Tick();

        // simulate memory
        memory(wbm_addr_o, wbm_dat_o, wbm_sel_o, wbm_cyc_o, wbm_stb_o, wbm_we_o, wbm_dat_i, wbm_ack_i, wbm_err_i);

        
        if (wbm_ack_i)
          num_test++;

        if(m_core->mem_data_o != data[num_test][MEM_DATA_O])
          ;//return num_test;

      }
    }
};

int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("stage_mem.vcd");

  const std::string &progfile = "tests/riscv-tests/rv32ui-p-add.elf";

  int ret = tb->Simulate(progfile);

  printf("\nStage MEM Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
