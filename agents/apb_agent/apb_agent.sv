class apb_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_agent)

//------------------------------------------
// Data Members
//------------------------------------------
apb_agent_config m_cfg;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(apb_trans) ap;
apb_monitor   m_monitor;
apb_sequencer m_sequencer;
apb_driver    m_driver;
apb_recorder m_recorder;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: apb_agent

function apb_agent::new(string name = "apb_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_agent::build_phase(uvm_phase phase);
    m_cfg = apb_agent_config::get_config(this);
  // Monitor is always present
  m_monitor = apb_monitor::type_id::create("m_monitor", this);
  m_monitor.m_cfg = m_cfg;

  m_recorder = apb_recorder::type_id::create("m_recorder", this);
  // Only build the driver and sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver = apb_driver::type_id::create("m_driver", this);
    m_driver.m_cfg = m_cfg;
    m_sequencer = apb_sequencer::type_id::create("m_sequencer", this);
  end
endfunction: build_phase

function void apb_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  ap.connect(m_recorder.analysis_export);
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction: connect_phase
