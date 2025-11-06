# ====================================================
# USER SETTINGS
# ====================================================
SIMULATOR = Questa
work       = work

RTL        = ../rtl/*
INC        = +incdir+../master_agent +incdir+../slave_agent +incdir+../test +incdir+../env
SVTB1      = ../env/top.sv
SVTB2      = ../test/axi_pkg.sv

COVOP      = -coverage +cover=bcft
VSIMOPT    = -vopt -voptargs=+acc
VSIMBATCH  = -c -do "log -r /*; run -all; exit"
VSIMBATCH1 = -c -do "log -r /*; coverage save -onexit med_cov0; run -all; exit"

# ====================================================
# TARGETS
# ====================================================

help:
	@echo "=============================================================="
	@echo "! make clean        -> Clean simulation files"
	@echo "! make sv_cmp       -> Compile design + testbench"
	@echo "! make run_test1    -> Run small packet test"
	@echo "! make view_wave1   -> View waveform for test1"
	@echo "=============================================================="

clean_Questa:
	rm -rf transcript* *.log vsim.wlf fcover* covhtml* *cov* *.wlf modelsim.ini work

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1)

run_test1_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) -l test1.log -sv_seed random work.top

view_wave1_Questa:
	vsim -view wave_file1.wlf
