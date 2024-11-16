class decoder_8b10b_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(decoder_8b10b_agent)

//------------------------------------------
// Data Members
//------------------------------------------
decoder_8b10b_agent_config m_cfg;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(decoder_8b10b_trans) ap;
decoder_8b10b_monitor   m_monitor;
decoder_8b10b_recorder m_recorder;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "decoder_8b10b_agent", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: decoder_8b10b_agent

function decoder_8b10b_agent::new(string name = "decoder_8b10b_agent", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void decoder_8b10b_agent::build_phase(uvm_phase phase);
    m_cfg = decoder_8b10b_agent_config::get_config(this);
    // Monitor is always present
    m_monitor = decoder_8b10b_monitor::type_id::create("m_monitor", this);
    m_monitor.m_cfg = m_cfg;

    m_recorder = decoder_8b10b_recorder::type_id::create("m_recorder", this);
endfunction: build_phase

function void decoder_8b10b_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  ap.connect(m_recorder.analysis_export);
endfunction: connect_phase
