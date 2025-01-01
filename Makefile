#
#------------------------------------------------------------------------------
#   Copyright 2018 Mentor Graphics Corporation
#   All Rights Reserved Worldwide
#
#   Licensed under the Apache License, Version 2.0 (the
#   "License"); you may not use this file except in
#   compliance with the License.  You may obtain a copy of
#   the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in
#   writing, software distributed under the License is
#   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied.  See
#   the License for the specific language governing
#   permissions and limitations under the License.
#------------------------------------------------------------------------------
TESTNAME := test
SEED := random
TIMESCALE := 1ns/10ps
UVM_VERBOSITY := UVM_MEDIUM
DO_COMMAND := "run 0; uvm setverbosity $(UVM_VERBOSITY); run -all; quit"

all: work build sim

tarball: clean_up tar

work:
	vlib work

rtl_build:
	vlog -64 -sv -incr -override_timescale $(TIMESCALE) -F ./RTL/rtl_filelist.f -l comp_rtl.log

env_build:
	vlog -64 -incr -override_timescale $(TIMESCALE) -F ./env_filelist.f -l comp_env.log

build:
	vlog -64 -sv -incr -override_timescale $(TIMESCALE) -F ./RTL/rtl_filelist.f -l comp_rtl.log
	vlog -64 -incr -override_timescale $(TIMESCALE) -F ./env_filelist.f -l comp_env.log

sim:
	vsim -64 -voptargs=+acc -msgmode both -classdebug -uvmcontrol=all -sv_seed $(SEED) +UVM_TESTNAME=$(TESTNAME) top -c -do $(DO_COMMAND) -wlf test.wlf -l sim.log

clean_up:
	rm -rf work ../*.tgz

tar:
	cd ../ ; \
	tar -zcf slave_agent/uvm_slave_agent.tgz \
	slave_agent/agents \
	slave_agent/rtl \
	slave_agent/tb \
	slave_agent/Makefile \
	slave_agent/README
