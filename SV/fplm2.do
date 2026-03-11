# Copyright 1991-2024 Mentor Graphics Corporation
# 
# Modification by Oklahoma State University
# Use with Testbench 
# James Stine, 2008
# Go Cowboys!!!!!!
#
# All Rights Reserved.
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION
# WHICH IS THE PROPERTY OF MENTOR GRAPHICS CORPORATION
# OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.

# Use this run.do file to run this example.
# Either bring up ModelSim and type the following at the "ModelSim>" prompt:
#     do run.do
# or, to run from a shell, type the following at the shell prompt:
#     vsim -do run.do -c
# (omit the "-c" to see the GUI while running from the shell)

onbreak {resume}

# create library
if [file exists work] {
    vdel -all
}
vlib work

# compile source files
vlog -lint *.sv *.v

# start and run simulation
vsim -voptargs=+acc work.tb_fplm2

# Diplays All Signals recursively
# add wave -hex -r /stimulus/*
#add wave -noupdate -divider -height 32 "fma16"
#add wave -color gold -hex /tb_fma16/clk
#add wave -hex /tb_fma16/dut/*
#add wave -noupdate -divider -height 32 "unpack"
#add wave -r -hex /tb_fma16/dut/unpack/*
#add wave -noupdate -divider -height 32 "fmaexpadd"
#add wave -hex /tb_fma16/dut/expadd1/*
#add wave -noupdate -divider -height 32 "fmamult"
#add wave -hex /tb_fma16/dut/mult1/*
#add wave -noupdate -divider -height 32 "fmasign"
#add wave -hex /tb_fma16/dut/sign1/*
#add wave -noupdate -divider -height 32 "fmaalign"
#add wave -hex /tb_fma16/dut/align1/*
#add wave -noupdate -divider -height 32 "fmaadd"
#add wave -hex /tb_fma16/dut/add1/*
##add wave -noupdate -divider -height 32 "lod64"
##add wave -hex /tb_fma16/dut/lod/*
#add wave -noupdate -divider -height 32 "fmashiftcalc"
#add wave -hex /tb_fma16/dut/fmashiftcalc/*
#add wave -noupdate -divider -height 32 "normshift"
#add wave -hex /tb_fma16/dut/normshift/*
#add wave -noupdate -divider -height 32 "resultsign"
#add wave -hex /tb_fma16/dut/resultsign/*
#add wave -noupdate -divider -height 32 "round"
#add wave -hex /tb_fma16/dut/round/*
#add wave -noupdate -divider -height 32 "flags"
#add wave -hex /tb_fma16/dut/flags1/*
#add wave -noupdate -divider -height 32 "specialcase"
#add wave -hex /tb_fma16/dut/specialcase1/*




run -all
quit

