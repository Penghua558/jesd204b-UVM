class rx_jesd204b_layering extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(rx_jesd204b_layering)

//------------------------------------------
// Data Members
//------------------------------------------
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(decoder_8b10b_trans) ap;
deser2dec_monitor m_deser2dec_monitor;
deser2dec_recorder m_deser2dec_recorder;

deserializer_agent m_deser_agent;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "rx_jesd204b_layering", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: rx_jesd204b_layering

function rx_jesd204b_layering::new(string name = "rx_jesd204b_layering", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void rx_jesd204b_layering::build_phase(uvm_phase phase);
    // Monitor is always present
    m_deser2dec_monitor = deser2dec_monitor::type_id::
        create("m_deser2dec_monitor", this);

    m_deser2dec_recorder = deser2dec_recorder::type_id::
        create("m_deser2dec_recorder", this);

    m_deser_agent = deserializer_agent::type_id::create("m_deser_agent", this);
endfunction: build_phase

function void rx_jesd204b_layering::connect_phase(uvm_phase phase);
    m_deser_agent.ap.connect(m_deser2dec_monitor.analysis_export);
    ap = m_deser2dec_monitor.ap;
    ap.connect(m_deser2dec_recorder.analysis_export);
endfunction: connect_phase
