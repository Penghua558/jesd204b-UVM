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
extern function void configure_rx_jesd204b_layering(
rx_jesd204b_layering_config cfg);
extern function void configure_deserializer_agent(
deserializer_agent_config cfg);
extern function void configure_enc_bus_agent(enc_bus_agent_config cfg);
// Standard UVM Methods:
extern function new(string name = "test_base", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void set_sequencers(test_vseq_base seq);
extern task run_phase(uvm_phase phase);

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

  configure_rx_jesd204b_layering(m_env_cfg.m_rx_jesd204b_layering_cfg);
  configure_enc_bus_agent(m_env_cfg.m_enc_bus_agent_cfg);

  `uvm_info("TEST", "environment configuration", UVM_LOW)
  m_env_cfg.print();

  if (!uvm_config_db #(virtual deserializer_monitor_bfm)::get(this, "", 
      "deserializer_monitor_bfm", 
      m_env_cfg.m_rx_jesd204b_layering_cfg.m_deserializer_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        deserializer monitor BFM)::get() failed");
  if (!uvm_config_db #(virtual deserializer_driver_bfm)::get(this, "", 
      "deserializer_driver_bfm", 
      m_env_cfg.m_rx_jesd204b_layering_cfg.m_deserializer_agent_cfg.drv_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        deserializer driver BFM)::get() failed");

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
  uvm_config_db #(rx_jesd204b_layering_config)::set(this, "m_env*", 
      "rx_jesd204b_layering_config", m_env_cfg.m_rx_jesd204b_layering_cfg);
  uvm_config_db #(deserializer_agent_config)::set(this, 
      "m_env.m_rx_jesd204b_layering*", "deserializer_agent_config", 
      m_env_cfg.m_rx_jesd204b_layering_cfg.m_deserializer_agent_cfg);
  uvm_config_db #(enc_bus_agent_config)::set(this, "m_env*", 
      "enc_bus_agent_config", m_env_cfg.m_enc_bus_agent_cfg);
endfunction: build_phase


// This can be overloaded by extensions to this base class
function void test_base::configure_rx_jesd204b_layering(
    rx_jesd204b_layering_config cfg);
    cfg.active = UVM_ACTIVE;
    assert(cfg.randomize());
    cfg.randomize_err_report = 1'b0;
    cfg.F = 8;
    cfg.K = 4;
    cfg.scrambling_enable = 1'b1;
    cfg.RBD = 4;
    cfg.erb_size = 4;
    configure_deserializer_agent(cfg.m_deserializer_agent_cfg);
endfunction: configure_rx_jesd204b_layering

function void test_base::configure_deserializer_agent(
    deserializer_agent_config cfg);
    cfg.active = UVM_ACTIVE;
    // maximum clock cycle delay between DUT's output and agent's input
    cfg.max_delay = 10*m_env_cfg.m_rx_jesd204b_layering_cfg.F;
    assert(cfg.randomize());
endfunction: configure_deserializer_agent 

function void test_base::configure_enc_bus_agent(enc_bus_agent_config cfg);
  cfg.active = UVM_ACTIVE;
endfunction: configure_enc_bus_agent

function void test_base::set_sequencers(test_vseq_base seq);
  seq.m_cfg = m_env_cfg;

  seq.enc_bus_sequencer_h = m_env.m_enc_bus_agent.m_sequencer;
endfunction


task test_base::run_phase(uvm_phase phase);
    ila_seq rx_jesd204_seq = ila_seq::type_id::create("rx_jesd204_seq");
    super.run_phase(phase);
    phase.raise_objection(this, "Waiting for reset");
    m_env_cfg.m_rx_jesd204b_layering_cfg.m_deserializer_agent_cfg.
        wait_for_reset();
    phase.drop_objection(this, "Reset finished");
    fork
        forever begin
            `uvm_info("ILA SEQ", "debug here?", UVM_MEDIUM)
            rx_jesd204_seq.start(m_env.m_rx_jesd204b_layering.m_ila_sequencer);
            `uvm_info("ILA SEQ", "debug here?", UVM_MEDIUM)
        end
    join_none
endtask
