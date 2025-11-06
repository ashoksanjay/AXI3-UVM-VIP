#!/usr/bin/perl
use strict;
use warnings;

my $INC = "+incdir+../env +incdir+../master_agent +incdir+../slave_agent +incdir+../test";
my $SVTB1 = "../rtl/axi_if.sv ../test/axi_pkg.sv";
my $SVTB = "../env/top.sv";

my $work = "work";

my $COVOP = "-coverage +cover=bcft";
my $VSIMOPT = "-vopt -voptargs=+acc";
#my $VSIMCOV = "log -r /*; run -all; exit";
my $VSIMBATCH = '-c -do "log -r /*; coverage save -onexit random_cov; run -all; exit"';
my $VSIMBATCH1 = '-c -do "log -r /*; coverage save -onexit fixed_cov; run -all; exit"';
my $VSIMBATCH2 = '-c -do "log -r /*; coverage save -onexit incr_cov; run -all; exit"';
my $VSIMBATCH3 = '-c -do "log -r /*; coverage save -onexit wrap_cov; run -all; exit"';

sub clean {
    system "rm -rf work transcript *.ini *.log *.wlf modelsim.ini *cov covhtml* fcover*";
    system "clear";
}

sub sv_cmp {
    system "vlib $work";
    system "vmap work $work";
    system "vlog -work $work $INC $SVTB1 $SVTB";
}

sub run_test {
    system "vsim $VSIMOPT $COVOP $VSIMBATCH -wlf wave_file1.wlf -l test1.log -sv_seed 2742195252 work.top +UVM_TESTNAME=random_seq_test";
    system "vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html random_cov";
}

sub run_test_fixed{
  system "vsim $VSIMOPT $COVOP $VSIMBATCH1 -wlf wave_file2.wlf -l test2.log -sv_seed 2295541058 work.top +UVM_TESTNAME=fixed_seq_test";
  system "vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html fixed_cov";
}

sub run_test_incr{
  system "vsim $VSIMOPT $COVOP $VSIMBATCH2 -wlf wave_file3.wlf -l test3.log -sv_seed 3350447564 work.top +UVM_TESTNAME=incr_seq_test";
  system "vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html incr_cov";
}

sub run_test_wrap{
  system "vsim $VSIMOPT $COVOP $VSIMBATCH3 -wlf wave_file4.wlf -l test4.log -sv_seed 355710581 work.top +UVM_TESTNAME=wrap_seq_test";
  system "vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html wrap_cov";
}

sub report_12{
  system "vcover merge -out axi_cov fixed_cov incr_cov";
  system "vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi_cov";
}

sub regress_12{
  clean();
  sv_cmp();
  run_test_fixed();
  run_test_incr();
  report_12();
}

sub report_123{
  system "vcover merge -out axi_cov fixed_cov incr_cov wrap_cov";
  system "vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi_cov";
}

sub regress_123{
  clean();
  sv_cmp();
  run_test_fixed();
  run_test_incr();
  run_test_wrap();
  report_123();
}

sub cov{
  system "firefox covhtmlreport/index.html &";
}

sub view_wave_fixed{
  system "vsim -view wave_file2.wlf";
}

sub view_wave_incr{
  system "vsim -view wave_file3.wlf";
}

sub view_wave_wrap{
  system "vsim -view wave_file4.wlf";
}

sub view_wave_random{
  system "vsim -view wave_file1.wlf";
}

sub view_wave{
  system "clear";
  print "F: FIXED WAVE\n";
  print "I: INCR WAVE\n";
  print "W: WRAP WAVE\n";
  print "R: RANDOM WAVE\n";
  print "----------------\n";
  
  print "Enter your choice: ";
  my $sh = <STDIN>;
  chomp($sh);
  
    if ($sh eq 'F' || $sh eq 'f'){
        view_wave_fixed();
    }
    elsif ($sh eq 'I' || $sh eq 'i'){
        view_wave_incr();
    }
    elsif ($sh eq 'W' || $sh eq 'w'){
        view_wave_wrap();
    }
    elsif ($sh eq 'R' || $sh eq 'r'){
        view_wave_random();
    }
    else{
      #sleep 1;
      system "clear";
      return;
    }
}

system "clear";
while (1) {
    print "-------------------------------\n";
    print "|1. CLEAN                     |\n";
    print "|2. COMPILE                   |\n";
    print "|3. RUN_TEST(RANDOM)          |\n";
    print "|4. RUN_TEST(FIXED)           |\n";
    print "|5. RUN_TEST(INCR)            |\n"; 
    print "|6. RUN_TEST(WRAP)            |\n";
    print "|7. REGRESS(FIXED, INCR)      |\n";
    print "|8. REGRESS(FIXED, INCR, WRAP)|\n";
    print "|9. COV                       |\n";
    print "|0. EXIT                      |\n";
    print "-------------------------------\n";
    print "Enter your choice: ";
    
    my $ch = <STDIN>;
    chomp($ch);
    
    if ($ch == 0) {
      last;
    }
    elsif ($ch == 1) {
        clean();
    }
    elsif ($ch == 2) {
        sv_cmp();
    }
    elsif ($ch == 3) {
        run_test();
    }
    elsif ($ch == 4) {
        run_test_fixed();
    }
    elsif ($ch == 5) {
        run_test_incr();
    }
    elsif ($ch == 6) {
        run_test_wrap();
    }
    elsif ($ch == 7) {
        regress_12();
    }
    elsif ($ch == 8) {
        regress_123();
    }
    elsif ($ch == 9) {
        cov();
    }
    elsif($ch == 11){
        view_wave();
        system "clear";
    }
    else {
        system "clear";
        print "Invalid choice. Try again.\n";
    }
}
