// Class Description:
// After setting dev_enable to 1, we randomize wdata and dev_bending 60 times.
//
class test extends uvm_test;

// UVM Factory Registration Macro
//
`uvm_component_utils(test)

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
extern function new(string name = "test", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task  main_phase(uvm_phase phase);

endclass: test

function test::new(string name = "test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void test::build_phase(uvm_phase phase);
  // env configuration
  m_env_cfg = env_config::type_id::create("m_env_cfg");

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
function void test::configure_pmd901_agent(pmd901_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.disable_spi_violation = 1'b0;
  cfg.disable_close2overheat = 1'b0;
  cfg.disable_overheat = 1'b0;
endfunction: configure_pmd901_agent

function void test::configure_apb_agent(apb_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.apb_index = 1;
  cfg.start_address[0] = 16'd0;
  cfg.range[0] = 16'd5;
endfunction: configure_apb_agent

task test::main_phase(uvm_phase phase);
    pmd901_sequence pmd901_seq = pmd901_sequence::type_id::create("pmd901_seq");

    pmd901_bus_enable_sequence pmd901_enable_seq = 
        pmd901_bus_enable_sequence::type_id::create("pmd901_enable_seq");
    pmd901_bus_rand_speed_bending_sequence pmd901_speed_seq = 
        pmd901_bus_rand_speed_bending_sequence::type_id::create(
        "pmd901_speed_seq");

    int i = 0;
    super.main_phase(phase);
    phase.raise_objection(this);
    fork
        begin
        // enable PMD901 first
            #3000ns;
            `uvm_info("TEST", "About to enable PMD901", UVM_MEDIUM)
            test_enable = 1'b1;
            pmd901_enable_seq.set_enable(test_enable, 
                m_env.m_pmd901_bus_agent.m_sequencer);
            `uvm_info("TEST", "Enabled PMD901", UVM_MEDIUM)
            pmd901_seq.read_n_drive(m_env.m_pmd901_agent.m_sequencer);
            repeat(40) begin
                i++;
                `uvm_info("TEST", $sformatf("sequence number: %0d/40", i), 
                    UVM_MEDIUM)
                pmd901_speed_seq.rand_speed_bending(test_enable, 
                    m_env.m_pmd901_bus_agent.m_sequencer);
                pmd901_seq.read_n_drive(m_env.m_pmd901_agent.m_sequencer);
            end
            `uvm_info("TEST", "Finished generating speed stimulus", UVM_MEDIUM)
        end
        begin
            // test should consume less than 1000us, if we are able to wait so
            // long, it must mean the test is stuck, so we ended it forcefully
            #1500us;
            `uvm_error("TEST", "Test does not ended normally")
        end
    join_any
    phase.drop_objection(this);
endtask
