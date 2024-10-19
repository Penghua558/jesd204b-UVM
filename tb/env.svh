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

//
// Class Description:
//
//
class env extends uvm_env;

// UVM Factory Registration Macro
//
`uvm_component_utils(env)
//------------------------------------------
// Data Members
//------------------------------------------
pmd901_agent m_pmd901_agent;
apb_agent m_apb_agent;

reg2apb_adapter m_reg2apb;
// Register predictor
uvm_reg_predictor#(apb_trans) m_apb2reg_predictor;
env_config m_cfg;

// Standard UVM Methods:
extern function new(string name = "env", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass:env

function env::new(string name = "env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void env::build_phase(uvm_phase phase);
    m_cfg = env_config::get_config(this);
    m_pmd901_agent = pmd901_agent::type_id::create("m_pmd901_agent", this);
    m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);

    m_apb2reg_predictor = uvm_reg_predictor#(apb_trans)::type_id::create(
        "m_apb2reg_predictor", this);
    m_reg2apb = reg2apb_adapter::type_id::create("m_reg2apb");
endfunction:build_phase

function void env::connect_phase(uvm_phase phase);
    // Only set up register sequencer layering if the spi_rb is the top block
    // If it isn't, then the top level environment will set up the correct 
    // sequencer and predictor
    if(m_cfg.spi_rb.get_parent() == null) begin
        if(m_cfg.m_apb_agent_cfg.active == UVM_ACTIVE) begin
          m_cfg.spi_rb.default_map.set_sequencer(
              m_apb_agent.m_sequencer, m_reg2apb);
        end

        //
        // Register prediction part:
        //
        // Replacing implicit register model prediction with explicit prediction
        // based on APB bus activity observed by the APB agent monitor
        // Set the predictor map:
        m_apb2reg_predictor.map = m_cfg.spi_rb.default_map;
        // Set the predictor adapter:
        m_apb2reg_predictor.adapter = m_reg2apb;
        // Disable the register models auto-prediction
        m_cfg.spi_rb.default_map.set_auto_predict(0);
        // Connect the predictor to the bus agent monitor analysis port
        m_apb_agent.ap.connect(m_apb2reg_predictor.bus_in);
    end
endfunction: connect_phase
