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
int f_position;
// Elastic RX Buffer, 1st index is position of frame in the buffer, 2nd index
// is octet position in a frame
erb m_erb;
rx_jesd204b_layering_config m_cfg;

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
    f_position = 0;
    ap = new("ap", this);
endfunction: build_phase


function void erb2ila_monitor::write(erb_trans t);
    // start of a frame, we create a new transaction to store a new frame
    ila_out = erb_trans::type_id::create("ila_out");
    ila_out.data = new[m_cfg.F];
    ila_out.is_control_word = new[m_cfg.F];
    ila_out.data = t.data;
    ila_out.is_control_word = t.is_control_word;


    // MSB should be the first octet ever received
    ila_out.data.reverse();
    ila_out.is_control_word.reverse();

    // tries to feed the frame into ERB
    if (m_erb.put(ila_out, t.ifsstate)) begin
        `uvm_info("CGS2ERB Monitor", "Fed a new frame into ERB", 
            UVM_MEDIUM)
    end

    if (m_erb.get(cloned_ila_out)) begin
        `uvm_info("CGS2ERB Monitor", "Sending out a new frame", 
            UVM_MEDIUM)
        // Clone and publish the cloned item to the subscribers
        notify_transaction(cloned_ila_out);
    end
    f_position = (f_position+1) % m_cfg.K;
endfunction


function void erb2ila_monitor::notify_transaction(ila_trans item);
    ap.write(item);
endfunction : notify_transaction
