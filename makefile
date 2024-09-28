##################################################################################
# This file is under MIT License												 #
# https://mit-license.org/														 #
# 																				 #
# Copyright (c) 2024 Totema														 #
# https://github.com/TotemaM													 #
##################################################################################

CC := gcc
VER :=
DBG = -g -O0 -Wall -Wextra -Wsign-compare -pedantic -Walloc-zero \
	  -Wduplicated-branches -Wduplicated-cond -Wfloat-equal -Wformat-signedness \
	  -Winit-self -Wlogical-op -Wformat=2 -Wnull-dereference \
	  -Wsuggest-attribute=const -Wswitch-default -Wswitch -Wundef \
	  -Wduplicated-cond -Wduplicated-branches -Wunused-result -Wformat-security \
	  -Wformat-overflow -Wformat-truncation -Wformat-signedness
BLD_DIR := build
OUT_DIR := out
$(shell mkdir -p $(OUT_DIR))

all: prog test

##################################################################################
# 							DEFAULT ENVIRONMENT 								 #	
##################################################################################
SRC_DIR := src
OUT := prog
SRC := $(shell find $(SRC_DIR) -type f -name *.c)
OBJ := $(patsubst $(SRC_DIR)/%.c, $(BLD_DIR)/%.o, $(SRC))
INC := -I $(SRC_DIR)
LIB :=
DEP := $(OBJ:.o=.d)

prog: $(OBJ)
	$(CC) $(VER) $(DBG) $^ -o $(OUT_DIR)/$(OUT) $(LIB) $(INC)

$(BLD_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(VER) $(DBG) -MMD -MP -c $< -o $@ $(INC)

-include $(DEP)

##################################################################################
# 							TESTING ENVIRONMENT 								 #
##################################################################################
TST_DIR := test
TST_OUT := test
TST_SRC := $(shell find $(TST_DIR) -type f -name '*.c')
TST_OBJ := $(patsubst $(TST_DIR)/%.c, $(BLD_DIR)/$(TST_DIR)/%.o, $(TST_SRC))
TST_OBJ += $(filter-out $(BLD_DIR)/main.o $(BLD_DIR)/main.d, $(OBJ))
TST_INC := $(INC) -I $(TST_DIR)
TST_LIB := $(LIB)
TST_DEP := $(TST_OBJ:.o=.d)

test: $(TST_OBJ)
	$(CC) $(VER) $(DBG) $^ -o $(OUT_DIR)/$(TST_OUT) $(TST_LIB) $(TST_INC)

$(BLD_DIR)/$(TST_DIR)/%.o: $(TST_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(VER) $(DBG) -MMD -MP -c $< -o $@ $(TST_INC)

-include $(TST_DEP)

##################################################################################
# 							ALTERNATIVE TARGETS									 #
##################################################################################

# Address and memory leak sanitizing
lsan: DBG += -fsanitize=leak,address,undefined
lsan: all
# Thread Sanitizing
tsan: DBG += -fsanitize=thread,undefined
tsan: all
# Production build
prod: DBG := -O3
prod: all

##################################################################################
#    							FAKE TARGETS     								 #
##################################################################################
.PHONY: clear

clear:  # Delete build directory and program
	rm -rf $(BLD_DIR) $(OUT_DIR)
	clear
