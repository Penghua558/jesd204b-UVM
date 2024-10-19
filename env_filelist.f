############
## agents ##
############
-F ./agents/apb_agent/apb_agent_filelist.f

#################
## environment ##
#################
./tb/register_model/spi_reg_pkg.sv
./tb/env_pkg.sv
./tb/sequences/apb_bus_sequence_lib_pkg.sv
./tb/sequences/test_seq_lib_pkg.sv
./tb/testcases/testcase_lib_pkg.sv
./tb/top.sv
