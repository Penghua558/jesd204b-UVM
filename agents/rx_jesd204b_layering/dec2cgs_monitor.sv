class dec2cgs_monitor extends uvm_subscriber#(decoder_8b10b_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(dec2cgs_monitor);

//------------------------------------------
// Data Members
//------------------------------------------
cgsnfs_trans cgs_out;
cgsnfs_trans cloned_cgs_out;
// running disparity
// 1 - RD+
// 0 - RD-
bit rd;
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
    ap = new("ap", this);
    rd = 1'b0;
endfunction: build_phase


function void dec2cgs_monitor::write(decoder_8b10b_trans t);
    `uvm_info("Received 8b10b decoder item", t.sprint(), UVM_MEDIUM)
    // if symbol is not locked then we don't need to process
    // deserializer_trans, since what it contains is garbage

    cgs_out = decoder_8b10b_trans::type_id::create("cgs_out");

    cgs_out.data = t.data;
    cgs_out.is_control_word = t.is_control_word;
    cgs_out.valid = !(t.disparity_error || t.not_in_table_error);
    cgs_out.sync_n = t.sync_n;

    cgs_out.cgsstate;
    cgs_out.ifsstate;
    cgs_out.sync_request;


    // Clone and publish the cloned item to the subscribers
    $cast(cloned_cgs_out, cgs_out.clone());
    notify_transaction(cloned_cgs_out);
    end
endfunction


function void dec2cgs_monitor::notify_transaction(
    cgsnfs_trans item);
    ap.write(item);
endfunction : notify_transaction
