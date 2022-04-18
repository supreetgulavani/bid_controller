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
BUILD_DIR 	:= work transcript *~ vsim.wlf *.log dgs.dbg dmslogdir

# sources 
SRCS	:= $(wildcard $(SRC_DIR)/*.sv)

# build recipies
all: setup compile opt $(TARGET)

setup:
		vlib work
		vmap work work

compile:
		vlog $(SRCS)

opt:
		vopt top -o top_optimized +acc "+cover=sbfec+bidder(rtl)."

release:
		
		vsim -coverage -vopt  work.top -c -do "coverage save -onexit -directive -cvg -codeall func_cov; run -all"

report:
		vcover report -verbose func_cov > report_func_cov.txt
		vcover report -html func_cov

build: all 

.PHONY: all clean setup compile opt report info

.DEFAULT_GOAL	:= build

clean:
		rm -rf $(BUILD_DIR) $(TARGET)
		@echo "Cleanup done!"

info:
	@echo "Application:" $(TARGET)
	@echo "Sources:" $(SRCS)
