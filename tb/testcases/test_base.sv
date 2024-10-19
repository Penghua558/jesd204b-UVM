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

bit test_enable;
bit test_bending;

//------------------------------------------
// Methods
//------------------------------------------
extern function void configure_pmd901_agent(pmd901_agent_config cfg);
extern function void configure_apb_agent(apb_agent_config cfg);
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
  m_env_cfg.spi_rb.build();
  m_env_cfg.spi_rb.lock_model();

  configure_pmd901_agent(m_env_cfg.m_pmd901_agent_cfg);
  configure_apb_agent(m_env_cfg.m_apb_agent_cfg);

  if (!uvm_config_db #(virtual pmd901_driver_bfm)::get(this, "", 
      "PMD901_drv_bfm", m_env_cfg.m_pmd901_agent_cfg.drv_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        pmd901_driver_bfm)::get() failed");
  if (!uvm_config_db #(virtual pmd901_monitor_bfm)::get(this, "", 
      "PMD901_mon_bfm", m_env_cfg.m_pmd901_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        pmd901_monitor_bfm)::get() failed");

  if (!uvm_config_db #(virtual apb_driver_bfm)::get(this, "", 
      "u_apb_driver_bfm", m_env_cfg.m_apb_agent_cfg.drv_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        apb_driver_bfm)::get(...) failed");
  if (!uvm_config_db #(virtual apb_monitor_bfm)::get(this, "", 
      "u_apb_monitor_bfm", m_env_cfg.m_apb_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual \
        apb_monitor_bfm)::get(...) failed");

  m_env = env::type_id::create("m_env", this);

  uvm_config_db #(uvm_object)::set(this, "m_env*", "env_config", m_env_cfg);
  uvm_config_db #(pmd901_agent_config)::set(this, "m_env*", 
      "pmd901_agent_config", m_env_cfg.m_pmd901_agent_cfg);
  uvm_config_db #(apb_agent_config)::set(this, "m_env*", 
      "apb_agent_config", m_env_cfg.m_apb_agent_cfg);
endfunction: build_phase


// This can be overloaded by extensions to this base class
function void test_base::configure_pmd901_agent(pmd901_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.disable_spi_violation = 1'b0;
  cfg.disable_close2overheat = 1'b0;
  cfg.disable_overheat = 1'b0;
endfunction: configure_pmd901_agent

function void test_base::configure_apb_agent(apb_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.apb_index = 0;
  cfg.start_address[0] = 16'd0;
  cfg.range[0] = 16'd10;
endfunction: configure_apb_agent

function void test_base::set_sequencers(test_vseq_base seq);
  seq.m_cfg = m_env_cfg;

  seq.pmd901_sequencer_h = m_env.m_pmd901_agent.m_sequencer;
endfunction
