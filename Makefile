OBJ_DIR = sim_obj
SRC_DIR = src
TESTS_DIR = tests
BUILD_DIR = build

OBJS = $(SRC_DIR)/Stage_IF.v $(TESTS_DIR)/stage_if_tb.cpp

OBJS2 = $(SRC_DIR)/ALU.v $(TESTS_DIR)/alu_tb.cpp

VERILATOR_CFLAGS = -CFLAGS "-std=c++11 -O3"
VERILATOR_OPTS = --Mdir $(OBJ_DIR) -Wno-lint --trace --exe 

default: run

run: $(OBJ_DIR)/VStage_IF $(OBJ_DIR)/VALU
	@$(OBJ_DIR)/VStage_IF | head
	@$(OBJ_DIR)/VALU | head

$(OBJ_DIR)/VStage_IF: $(OBJS)
	@verilator -Wall $(VERILATOR_CFLAGS) $(VERILATOR_OPTS) --cc $^
	@make -C $(OBJ_DIR) -j -f VStage_IF.mk VStage_IF

$(OBJ_DIR)/VALU: $(OBJS2)
	@verilator -Wall $(VERILATOR_CFLAGS) $(VERILATOR_OPTS) --cc $^
	@make -C $(OBJ_DIR) -j -f VALU.mk VALU

clean:
	@rm -r $(OBJ_DIR) *.vcd