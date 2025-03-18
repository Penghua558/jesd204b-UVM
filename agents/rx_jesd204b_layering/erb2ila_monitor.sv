class erb2ila_monitor extends uvm_subscriber#(erb_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(erb2ila_monitor);


//------------------------------------------
// Data Members
//------------------------------------------
ila_trans ila_out;
ila_trans cloned_ila_out;
// position of frame within a multiframe
// 0 ~ K-1
rx_jesd204b_layering_config m_cfg;
ILA_StateMachine m_ila_fsm;

//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(ila_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "erb2ila_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void write(erb_trans t);

// Proxy Methods:
extern function void notify_transaction(ila_trans item);
// Helper Methods:

endclass: erb2ila_monitor


function erb2ila_monitor::new(string name = "erb2ila_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction


function void erb2ila_monitor::build_phase(uvm_phase phase);
    m_cfg = rx_jesd204b_layering_config::get_config(this);
    ap = new("ap", this);
    m_ila_fsm = new();
    m_ila_fsm.m_ila_info_extractor = m_cfg.m_ila_info_extractor;
endfunction: build_phase


function void erb2ila_monitor::write(erb_trans t);
    // start of a frame, we create a new transaction to store a new frame
    ila_out = ila_trans::type_id::create("ila_out");
    ila_out.data = new[m_cfg.F];
    ila_out.is_control_word = new[m_cfg.F];
    ila_out.data = t.data;
    ila_out.is_control_word = t.is_control_word;
    ila_out.f_position = t.f_position;

    // FSM in this monitor only observes, it does not drive
    // the reason FSMs in dec2cgs_monitor drive is because those actions are
    // all contained in that layer. This FSM's drive action will be carried
    // out via transactions for lower layer, so this FSM will drive in its
    // corresponding layered sequence.
    m_ila_fsm.get_nextstate(t);
    m_ila_fsm.update_currentstate();

    // Clone and publish the cloned item to the subscribers
    $cast(cloned_ila_out, ila_out.clone());
    notify_transaction(cloned_ila_out);
endfunction


function void erb2ila_monitor::notify_transaction(ila_trans item);
    ap.write(item);
endfunction : notify_transaction
