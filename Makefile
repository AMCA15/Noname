#=======================================================================
# Makefile for Noname Project
# Anderson Contreras
#-----------------------------------------------------------------------
include pprint.mk

#--------------------------------------------------------------------
# Directories
#--------------------------------------------------------------------
OBJ_DIR   = sim_obj
SRC_DIR   = rtl
TESTS_DIR = tests
EXTRA_DIR = tests_extra

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------
objs_basename = $(basename $(notdir $(wildcard $(SRC_DIR)/*.v)))
objs_no_test  = $(patsubst %_tb.cpp, %, $(notdir $(filter-out $(objs_basename), $(wildcard $(TESTS_DIR)/*_tb.cpp))))
objs_verilate = $(addsuffix .verilate, $(objs_basename))
objs_compile  = $(addprefix V, $(addsuffix .compile, $(objs_no_test)))
objs_run  	  = $(addprefix V, $(addsuffix .run, $(objs_no_test)))
objs_extra	  = $(wildcard $(EXTRA_DIR)/*.cpp)


#--------------------------------------------------------------------
# Build Rules
#--------------------------------------------------------------------
VERILATOR_CFLAGS = -CFLAGS "-std=c++11 -O3 -I../$(EXTRA_DIR)"
VERILATOR_OPTS = -Wall --Mdir $(OBJ_DIR) -y $(SRC_DIR) -Wno-lint --trace --exe 

INCS = -I /mingw$(shell getconf LONG_BIT)/include/libelf -I../$(EXTRA_DIR)
VERILATOR_CFLAGS = -CFLAGS "-std=c++11 -O3 $(INCS)" -LDFLAGS "-lelf"
VERILATOR_OPTS = -Wall --Mdir $(OBJ_DIR) -y $(SRC_DIR) -Wno-lint --trace --exe

#--------------------------------------------------------------------
# Default
#--------------------------------------------------------------------
default: run

#--------------------------------------------------------------------
# Build, compile and run Testbenchs
#--------------------------------------------------------------------
verilate: $(objs_verilate)
	@printf "%b" "$(.NO_COLOR)$(.VER_STRING) $(.OK_COLOR)$(.OK_STRING)$(.NO_COLOR)\n\n"

compile: verilate $(objs_compile)
	@printf "%b" "$(.NO_COLOR)Compilation $(.OK_COLOR)$(.OK_STRING)$(.NO_COLOR)\n\n"

run: compile $(objs_run)

#--------------------------------------------------------------------

$(objs_verilate): %.verilate: $(SRC_DIR)/%.v
	@printf "%b" "$(.COM_COLOR)$(.VER_STRING)$(.OBJ_COLOR) $<$(.NO_COLOR)\n"
	@verilator $(VERILATOR_CFLAGS) $(VERILATOR_OPTS) --cc $< --top-module $(basename $(notdir $<)) $(patsubst %.verilate, $(TESTS_DIR)/%_tb.cpp, $@) $(objs_extra)


$(objs_compile): %.compile: $(OBJ_DIR)/%.mk
	@printf "%b" "$(.COM_COLOR)$(.COM_STRING)$(.OBJ_COLOR) $< $(.NO_COLOR)\n"
	@make --quiet -C $(OBJ_DIR) -j -f $(patsubst %.compile, %.mk, $@) $(patsubst %.compile, %, $@)
	

$(objs_run): %.run: $(OBJ_DIR)/%.exe
	@printf "%b" "\n$(.COM_COLOR)Running$(.OBJ_COLOR)"
	@$< | head

#--------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------
clean:
	@rm -rf $(OBJ_DIR) *.vcd