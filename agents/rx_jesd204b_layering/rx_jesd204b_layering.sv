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
uvm_analysis_port #(erb_trans) ap;

rx_jesd204b_layering_config m_cfg;

decoder_sequencer dec_sequencer;
cgsnfs_sequencer cgs_sequencer;
// I couldn't come up with a suitable name for this variable 
// other than erb_sequencer, so erb_m_sequencer is my best shot
erb_sequencer erb_m_sequencer;

cgs2erb_monitor m_cgs2erb_monitor;
cgs2erb_recorder m_cgs2erb_recorder;
ila_extractor m_ila_extractor;

dec2cgs_monitor m_dec2cgs_moitor;
dec2cgs_recorder m_dec2cgs_recorder;

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
extern task run_phase(uvm_phase phase);
endclass: rx_jesd204b_layering

function rx_jesd204b_layering::new(string name = "rx_jesd204b_layering", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void rx_jesd204b_layering::build_phase(uvm_phase phase);
    ap = new("ap", this);
    m_cfg = rx_jesd204b_layering_config::get_config(this);
    // Monitor is always present
    m_cgs2erb_monitor = cgs2erb_monitor::type_id::
        create("m_cgs2erb_monitor", this);

    m_cgs2erb_recorder = cgs2erb_recorder::type_id::
        create("m_cgs2erb_recorder", this);

    m_ila_extractor = ila_extractor::type_id::create("m_ila_extractor", this);

    m_dec2cgs_moitor = dec2cgs_monitor::type_id::
        create("m_dec2cgs_moitor", this);

    m_dec2cgs_recorder = dec2cgs_recorder::type_id::
        create("m_dec2cgs_recorder", this);

    m_deser2dec_monitor = deser2dec_monitor::type_id::
        create("m_deser2dec_monitor", this);

    m_deser2dec_recorder = deser2dec_recorder::type_id::
        create("m_deser2dec_recorder", this);

    m_deser_agent = deserializer_agent::type_id::create("m_deser_agent", this);

    if (m_cfg.active == UVM_ACTIVE) begin
        dec_sequencer = decoder_sequencer::type_id::create(
            "dec_sequencer", this);
        cgs_sequencer = cgsnfs_sequencer::type_id::create(
            "cgs_sequencer", this);
        erb_m_sequencer = erb_sequencer::type_id::create(
            "erb_m_sequencer", this);
    end
endfunction: build_phase

function void rx_jesd204b_layering::connect_phase(uvm_phase phase);
    m_deser_agent.ap.connect(m_deser2dec_monitor.analysis_export);
    m_deser2dec_monitor.ap.connect(m_dec2cgs_moitor.analysis_export);
    m_dec2cgs_moitor.ap.connect(m_cgs2erb_monitor.analysis_export);

    ap = m_cgs2erb_monitor.ap;

    m_deser2dec_monitor.ap.connect(m_deser2dec_recorder.analysis_export);
    m_dec2cgs_moitor.ap.connect(m_dec2cgs_recorder.analysis_export);
    m_dec2cgs_moitor.ap.connect(cgs_sequencer.sequencer_export);
    m_cgs2erb_monitor.ap.connect(m_cgs2erb_recorder.analysis_export);
    m_cgs2erb_monitor.ap.connect(m_ila_extractor.analysis_export);
    m_cgs2erb_monitor.ap.connect(erb_m_sequencer.analysis_export);
endfunction: connect_phase

task rx_jesd204b_layering::run_phase(uvm_phase phase);
    dec8b10b2des_seq dec2des_seq;
    cgsnfs2dec_seq cgs2dec_seq;
    erb2cgs_seq erb2cgs_m_seq;
    super.run_phase(phase);

    dec2des_seq = dec8b10b2des_seq::type_id::create("dec2des_seq", this);
    cgs2dec_seq = cgsnfs2dec_seq::type_id::create("cgs2dec_seq", this);
    erb2cgs_m_seq = erb2cgs_seq::type_id::create("erb2cgs_m_seq", this);

    // connect translation sequences to their respective upstream sequencers
    dec2des_seq.up_sequencer = dec_sequencer;
    cgs2dec_seq.up_sequencer = cgs_sequencer;
    erb2cgs_m_seq.up_sequencer = erb_m_sequencer;

    // start the translation sequences
    fork
        erb2cgs_m_seq.start(cgs_sequencer);
        cgs2dec_seq.start(dec_sequencer);
        dec2des_seq.start(m_deser_agent.m_sequencer);
    join_none
endtask
