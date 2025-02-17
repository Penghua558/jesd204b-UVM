//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
`ifndef env_config
`define env_config

//
// Class Description:
//
//
class env_config extends uvm_object;

localparam string s_my_config_id = "env_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(env_config)

//------------------------------------------
// Data Members
//------------------------------------------
rx_jesd204b_layering_config m_rx_jesd204b_layering_cfg;
enc_bus_agent_config m_enc_bus_agent_cfg;

//------------------------------------------
// Methods
//------------------------------------------
extern static function env_config get_config( uvm_component c);
extern function void do_print(uvm_printer printer);
extern function new(string name = "env_config");

endclass: env_config

function env_config::new(string name = "env_config");
  super.new(name);
    m_rx_jesd204b_layering_cfg = rx_jesd204b_layering_config::type_id::create(
      "m_rx_jesd204b_layering_cfg");
    m_enc_bus_agent_cfg = enc_bus_agent_config::type_id::create(
      "m_enc_bus_agent_cfg");
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function env_config env_config::get_config( uvm_component c );
  uvm_object o;
  env_config t;

  if( !uvm_config_db #(uvm_object)::get(c, "", s_my_config_id , o ) ) begin
    c.uvm_report_error( s_no_config_id ,
                        $sformatf("no config associated with %s" ,
                                  s_my_config_id ) ,
                        UVM_NONE , `uvm_file , `uvm_line  );
    return null;
  end

  if( !$cast( t , o ) ) begin
    c.uvm_report_error( s_my_config_type_error_id ,
                        $sformatf("config %s associated with config %s is \
                        not of type my_config" , o.sprint() , s_my_config_id ) ,
                        UVM_NONE , `uvm_file , `uvm_line );
  end

  return t;
endfunction

function void env_config::do_print(uvm_printer printer);
    m_rx_jesd204b_layering_cfg.print();
    m_enc_bus_agent_cfg.print();
    //super.do_print(printer);
endfunction:do_print

`endif // env_config
