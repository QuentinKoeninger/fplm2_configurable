#!/bin/bash

source .venv/bin/activate

python3 testvectorgen.py

/home/quentinkoeninger/altera_pro/26.1.1/questa_fse/bin/vsim -do fplm2_conf.do -c

python3 testsynthresults.py
