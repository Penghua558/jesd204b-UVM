class deserializer_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(deserializer_agent)

//------------------------------------------
// Data Members
//------------------------------------------
deserializer_agent_config m_cfg;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(deserializer_trans) ap;
deserializer_monitor m_monitor;
deserializer_recorder m_recorder;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "deserializer_agent", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: deserializer_agent

function deserializer_agent::new(string name = "deserializer_agent", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void deserializer_agent::build_phase(uvm_phase phase);
    m_cfg = deserializer_agent_config::get_config(this);
    // Monitor is always present
    m_monitor = deserializer_monitor::type_id::create("m_monitor", this);
    m_monitor.m_cfg = m_cfg;

    m_recorder = deserializer_recorder::type_id::create("m_recorder", this);
endfunction: build_phase

function void deserializer_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  ap.connect(m_recorder.analysis_export);
endfunction: connect_phase
