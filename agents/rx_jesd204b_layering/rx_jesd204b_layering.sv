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
uvm_analysis_port #(ila_trans) ap;

rx_jesd204b_layering_config m_cfg;

decoder_sequencer dec_sequencer;
cgsnfs_sequencer cgs_sequencer;
// I couldn't come up with a suitable name for this variable 
// other than ila_sequencer, so ila_m_sequencer is my best shot
ila_sequencer ila_m_sequencer;

cgs2ila_monitor m_cgs2ila_monitor;
cgs2ila_recorder m_cgs2ila_recorder;

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
    m_cgs2ila_monitor = cgs2ila_monitor::type_id::
        create("m_cgs2ila_monitor", this);

    m_cgs2ila_recorder = cgs2ila_recorder::type_id::
        create("m_cgs2ila_recorder", this);

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
        ila_m_sequencer = ila_sequencer::type_id::create(
            "ila_m_sequencer", this);
    end
endfunction: build_phase

function void rx_jesd204b_layering::connect_phase(uvm_phase phase);
    m_deser_agent.ap.connect(m_deser2dec_monitor.analysis_export);
    m_deser2dec_monitor.ap.connect(m_dec2cgs_moitor.analysis_export);
    m_dec2cgs_moitor.ap.connect(m_cgs2ila_monitor.analysis_export);

    ap = m_cgs2ila_monitor.ap;

    m_deser2dec_monitor.ap.connect(m_deser2dec_recorder.analysis_export);
    m_dec2cgs_moitor.ap.connect(m_dec2cgs_recorder.analysis_export);
    m_dec2cgs_moitor.ap.connect(cgs_sequencer.sequencer_export);
    m_cgs2ila_monitor.ap.connect(m_cgs2ila_recorder.analysis_export);
endfunction: connect_phase

task rx_jesd204b_layering::run_phase(uvm_phase phase);
    dec8b10b2des_seq dec2des_seq;
    cgsnfs2dec_seq cgs2dec_seq;
    ila2cgs_seq ila2cgs_m_seq;
    super.run_phase(phase);

    dec2des_seq = dec8b10b2des_seq::type_id::create("dec2des_seq", this);
    cgs2dec_seq = cgsnfs2dec_seq::type_id::create("cgs2dec_seq", this);
    ila2cgs_m_seq = ila2cgs_seq::type_id::create("ila2cgs_m_seq", this);

    // connect translation sequences to their respective upstream sequencers
    dec2des_seq.up_sequencer = dec_sequencer;
    cgs2dec_seq.up_sequencer = cgs_sequencer;
    ila2cgs_m_seq.up_sequencer = ila_m_sequencer;

    // start the translation sequences
    fork
        ila2cgs_m_seq.start(cgs_sequencer);
        cgs2dec_seq.start(dec_sequencer);
        dec2des_seq.start(m_deser_agent.m_sequencer);
    join_none
endtask
