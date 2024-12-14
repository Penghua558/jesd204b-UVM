class cgs2ila_monitor extends uvm_subscriber#(cgsnfs_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(cgs2ila_monitor);

//------------------------------------------
// Data Members
//------------------------------------------
ila_trans ila_out;
ila_trans cloned_ila_out;
rx_jesd204b_layering_config m_cfg;

//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(ila_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "cgs2ila_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void write(cgsnfs_trans t);

// Proxy Methods:
extern function void notify_transaction(ila_trans item);
// Helper Methods:

endclass: cgs2ila_monitor

function cgs2ila_monitor::new(string name = "cgs2ila_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void cgs2ila_monitor::build_phase(uvm_phase phase);
    m_cfg = rx_jesd204b_layering_config::get_config(this);
    ap = new("ap", this);
endfunction: build_phase


function void cgs2ila_monitor::write(cgsnfs_trans t);
    // if symbol is not locked then we don't need to process
    // deserializer_trans, since what it contains is garbage

    ila_out = decoder_8b10b_trans::type_id::create("cgs_out");

    // Clone and publish the cloned item to the subscribers
    $cast(cloned_ila_out, ila_out.clone());
    notify_transaction(cloned_ila_out);
endfunction


function void cgs2ila_monitor::notify_transaction(ila_trans item);
    ap.write(item);
endfunction : notify_transaction
