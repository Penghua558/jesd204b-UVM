// Class Description:
class test_base extends uvm_test;

// UVM Factory Registration Macro
//
`uvm_component_utils(test_base)

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Component Members
//------------------------------------------
// The environment class
env m_env;
// Configuration objects
env_config m_env_cfg;

//------------------------------------------
// Methods
//------------------------------------------
extern function void configure_decoder_8b10b_agent(
decoder_8b10b_agent_config cfg);
extern function void configure_enc_bus_agent(enc_bus_agent_config cfg);
// Standard UVM Methods:
extern function new(string name = "test_base", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void set_sequencers(test_vseq_base seq);

endclass: test_base

function test_base::new(string name = "test_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void test_base::build_phase(uvm_phase phase);
  // env configuration
  m_env_cfg = env_config::type_id::create("m_env_cfg");
  // Register model
  // Enable all types of coverage available in the register model
  uvm_reg::include_coverage("*", UVM_CVR_ALL);
  // Create the register model:
  // m_env_cfg.spi_rb.build();
  // m_env_cfg.spi_rb.lock_model();

  configure_decoder_8b10b_agent(m_env_cfg.m_decoder_8b10b_agent_cfg);
  configure_enc_bus_agent(m_env_cfg.m_enc_bus_agent_cfg);

  if (!uvm_config_db #(virtual decoder_8b10b_monitor_bfm)::get(this, "", 
      "dec_8b10b_mon_bfm", m_env_cfg.m_decoder_8b10b_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        8b10b decoder_monitor BFM)::get() failed");

  if (!uvm_config_db #(virtual enc_bus_monitor_bfm)::get(this, "", 
      "enc_bus_mon_bfm", m_env_cfg.m_enc_bus_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        encoder bus_monitor)::get(...) failed");
  if (!uvm_config_db #(virtual enc_bus_driver_bfm)::get(this, "", 
      "enc_bus_drv_bfm", m_env_cfg.m_enc_bus_agent_cfg.drv_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        encoder bus driver)::get(...) failed");

  m_env = env::type_id::create("m_env", this);

  uvm_config_db #(uvm_object)::set(this, "m_env*", "env_config", m_env_cfg);
  uvm_config_db #(decoder_8b10b_agent_config)::set(this, "m_env*", 
      "decoder_8b10b_agent_config", m_env_cfg.m_decoder_8b10b_agent_cfg);
  uvm_config_db #(enc_bus_agent_config)::set(this, "m_env*", 
      "enc_bus_agent_config", m_env_cfg.m_enc_bus_agent_cfg);
endfunction: build_phase


// This can be overloaded by extensions to this base class
function void test_base::configure_decoder_8b10b_agent(
    decoder_8b10b_agent_config cfg);
    cfg.active = UVM_PASSIVE;
endfunction: configure_decoder_8b10b_agent

function void test_base::configure_enc_bus_agent(enc_bus_agent_config cfg);
  cfg.active = UVM_ACTIVE;
endfunction: configure_enc_bus_agent

function void test_base::set_sequencers(test_vseq_base seq);
  seq.m_cfg = m_env_cfg;

  seq.enc_bus_sequencer_h = m_env.m_enc_bus_agent.m_sequencer;
endfunction
