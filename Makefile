######################################################################
# ECE593 - Fundamentals of Pre-Silicon Validation
#			Bid Controller
#
# Group 16: Supreet Gulavani, Sreeja Boyina
######################################################################
#comment
# Target
TARGET		:= bid_controller

# Directories for source files and builds
SRC_DIR 	:= src
BUILD_DIR 	:= work transcript *~ vsim.wlf *.log dgs.dbg dmslogdir covhtmlreport

# sources 
SRCS	:= $(wildcard $(SRC_DIR)/*.sv)

# build recipies
all: setup compile opt $(TARGET)

setup:
		vlib work
		vmap work work

compile:
		vlog -coveropt 3 +cover=sbfec +acc $(SRCS)

#opt:
		#vopt top -o top_optimized +acc

release:
		
		vsim -coverage -vopt work.top -c -do "coverage save -onexit -directive -cvg -codeAll func_cov; run -all"

report:
		vcover report -verbose func_cov > report_func_cov.txt
html:
		vcover report -html func_cov

build: all 

.PHONY: all clean setup compile opt release report html info

.DEFAULT_GOAL	:= build

clean:
		rm -rf $(BUILD_DIR) $(TARGET)
		@echo "Cleanup done!"

info:
	@echo "Application:" $(TARGET)
	@echo "Sources:" $(SRCS)
