class dec2cgs_monitor extends uvm_subscriber#(decoder_8b10b_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(dec2cgs_monitor);

//------------------------------------------
// Data Members
//------------------------------------------
cgsnfs_trans cgs_out;
cgsnfs_trans cloned_cgs_out;
CGS_StateMachine cgs_fsm;
IFS_StateMachine ifs_fsm;
rx_jesd204b_layering_config m_cfg;

//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(cgsnfs_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "dec2cgs_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void write(decoder_8b10b_trans t);

// Proxy Methods:
extern function void notify_transaction(cgsnfs_trans item);
// Helper Methods:

endclass: dec2cgs_monitor

function dec2cgs_monitor::new(string name = "dec2cgs_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void dec2cgs_monitor::build_phase(uvm_phase phase);
    m_cfg = rx_jesd204b_layering_config::get_config(this);
    ifs_fsm.m_cfg = m_cfg;
    ap = new("ap", this);
    cgs_fsm = new;
    ifs_fsm = new;
endfunction: build_phase


function void dec2cgs_monitor::write(decoder_8b10b_trans t);
    `uvm_info("Received 8b10b decoder item", t.sprint(), UVM_MEDIUM)
    // if symbol is not locked then we don't need to process
    // deserializer_trans, since what it contains is garbage

    cgs_out = cgsnfs_trans::type_id::create("cgs_out");

    cgs_out.data = t.data;
    cgs_out.is_control_word = t.is_control_word;
    cgs_out.valid = !(t.disparity_error || t.not_in_table_error);
    cgs_out.sync_n = t.sync_n;

    // fill outcoming CGS transaction's CGS state & update CGS state
    cgs_fsm.state_func(cgs_out);
    cgs_fsm.get_nextstate(t);
    cgs_fsm.update_currentstate();

    ifs_fsm.state_func(cgs_out);
    ifs_fsm.get_nextstate(cgs_out);
    ifs_fsm.update_currentstate();


    // Clone and publish the cloned item to the subscribers
    $cast(cloned_cgs_out, cgs_out.clone());
    notify_transaction(cloned_cgs_out);
endfunction


function void dec2cgs_monitor::notify_transaction(
    cgsnfs_trans item);
    ap.write(item);
endfunction : notify_transaction
