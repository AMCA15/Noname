#=======================================================================
# Makefile for Noname Project
# Anderson Contreras
#-----------------------------------------------------------------------

#--------------------------------------------------------------------
# Directories
#--------------------------------------------------------------------
OBJ_DIR = sim_obj
SRC_DIR = src
TESTS_DIR = tests
BUILD_DIR = build

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------
OBJS = $(patsubst $(SRC_DIR)/%.v,%, $(wildcard $(SRC_DIR)/*.v))

#--------------------------------------------------------------------
# Build Rules
#--------------------------------------------------------------------
VERILATOR_CFLAGS = -CFLAGS "-std=c++11 -O3"
VERILATOR_OPTS = --Mdir $(OBJ_DIR) -Wno-lint --trace --exe 


define _compile_1

@verilator -Wall $(VERILATOR_CFLAGS) $(VERILATOR_OPTS) --cc $(patsubst %,$(SRC_DIR)/%.v, $(1)) $(patsubst %,$(TESTS_DIR)/%_tb.cpp, $(1))
endef


define _compile_2
	
@make -C $(OBJ_DIR) -j -f $(patsubst %,V%.mk, $(1)) $(patsubst %,V%, $(1))
endef


define _run

@$(OBJ_DIR)/$(patsubst %,V%, $(1)) | head
endef

#--------------------------------------------------------------------
# Default
#--------------------------------------------------------------------
default: |run

#--------------------------------------------------------------------
# Build and run Testbenchs
#--------------------------------------------------------------------
.pre-compile:
	$(foreach objs, $(OBJS), $(call _compile_1, $(objs)))

compile: .pre-compile
	$(foreach objs, $(OBJS), $(call _compile_2, $(objs)))

run: compile
	$(foreach objs, $(OBJS), $(call _run, $(objs)))

#--------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------
clean:
	@rm -r $(OBJ_DIR) *.vcd