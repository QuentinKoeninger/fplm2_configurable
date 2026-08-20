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
vlog -lint tb_fplm2_conf_16_32.sv fplm2.sv conf_mul_fplm2_16_32.sv fplm2_conf_16.sv fplm2ExpAdd.sv fplm2ExpAddConf.sv fplm2MpAddConf.sv fplm2MpAdd.sv mul_fplm2_32.sv mul_fplm2.sv fplm2_32.sv fplm2ExpAdd_32.sv fplm2MpAdd_32.sv

# start and run simulation
vsim -voptargs=+acc work.tb_fplm2_conf_16_32

# Diplays All Signals recursively




run -all
quit

