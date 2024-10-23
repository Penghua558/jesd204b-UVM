class enc_bus_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(enc_bus_agent)

//------------------------------------------
// Data Members
//------------------------------------------
enc_bus_agent_config m_cfg;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(enc_bus_trans) ap;
enc_bus_monitor   m_monitor;
enc_bus_sequencer m_sequencer;
enc_bus_driver    m_driver;
enc_bus_recorder m_recorder;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "enc_bus_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: enc_bus_agent

function enc_bus_agent::new(string name = "enc_bus_agent", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void enc_bus_agent::build_phase(uvm_phase phase);
    m_cfg = enc_bus_agent_config::get_config(this);
    // Monitor is always present
    m_monitor = enc_bus_monitor::type_id::create("m_monitor", this);
    m_monitor.m_cfg = m_cfg;

  m_recorder = enc_bus_recorder::type_id::create("m_recorder", this);
  // Only build the driver and sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver = enc_bus_driver::type_id::create("m_driver", this);
    m_driver.m_cfg = m_cfg;
    m_sequencer = enc_bus_sequencer::type_id::create("m_sequencer", this);
  end
endfunction: build_phase

function void enc_bus_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  ap.connect(m_recorder.analysis_export);
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction: connect_phase
