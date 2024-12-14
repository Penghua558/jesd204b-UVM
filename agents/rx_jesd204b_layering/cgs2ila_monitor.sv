class cgs2ila_monitor extends uvm_subscriber#(cgsnfs_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(cgs2ila_monitor);

//------------------------------------------
// Data Members
//------------------------------------------
ila_trans ila_out;
ila_trans cloned_ila_out;
// position of frame within a multiframe
// 0 ~ K-1
int f_position;
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
    f_position = 0;
    ap = new("ap", this);
endfunction: build_phase


function void cgs2ila_monitor::write(cgsnfs_trans t);
    if (t.o_position == 0 && t.valid) begin
    // start of a frame, we create a new transaction to store a new frame
        `uvm_info("CGS2ILA Monitor", "Start of a new frame", UVM_HIGH)
        ila_out = decoder_8b10b_trans::type_id::create("cgs_out");
        ila_out.data = new[m_cfg.F];
        ila_out.data[t.o_position] = t.data;
        ila_out.f_position = f_position;
    end else begin
        assert(ila_out != null);
        ila_out.data[t.o_position] = t.data;

        if (t.o_position == (m_cfg.F-1)) begin
            `uvm_info("CGS2ILA Monitor", "Sending out a new frame", UVM_HIGH)
            // Clone and publish the cloned item to the subscribers
            $cast(cloned_ila_out, ila_out.clone());
            notify_transaction(cloned_ila_out);

            f_position = (f_position++) % m_cfg.K;
        end
    end
endfunction


function void cgs2ila_monitor::notify_transaction(ila_trans item);
    ap.write(item);
endfunction : notify_transaction
