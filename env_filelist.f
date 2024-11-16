############
## agents ##
############
#-F ./agents/apb_agent/apb_agent_filelist.f
-F ./agents/enc_bus_agent/enc_bus_agent_filelist.f
-F ./agents/decoder_8b10b_agent/decoder_8b10b_agent_filelist.f
-F ./agents/deserializer_agent/deserializer_agent_filelist.f

#################
## environment ##
#################
#./tb/register_model/spi_reg_pkg.sv
./tb/table_8b10b_pkg.sv
./tb/env_pkg.sv
./tb/sequences/test_seq_lib_pkg.sv
./tb/testcases/testcase_lib_pkg.sv
./tb/top.sv
