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
deserializer_sequencer m_sequencer;
deserializer_driver m_driver;
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

    // Only build the driver and sequencer if active
    if(m_cfg.active == UVM_ACTIVE) begin
        m_driver = deserializer_driver::type_id::create("m_driver", this);
        m_driver.m_cfg = m_cfg;
        m_sequencer = deserializer_sequencer::type_id::create
        ("m_sequencer", this);
    end
endfunction: build_phase

function void deserializer_agent::connect_phase(uvm_phase phase);
    ap = m_monitor.ap;
    ap.connect(m_recorder.analysis_export);
    // Only connect the driver and the sequencer if active
    if(m_cfg.active == UVM_ACTIVE) begin
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
endfunction: connect_phase
