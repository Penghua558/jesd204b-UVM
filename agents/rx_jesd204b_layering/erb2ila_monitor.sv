import cgs2erb_monitor_dec::*;
class cgs2erb_monitor extends uvm_subscriber#(cgsnfs_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(cgs2erb_monitor);


//------------------------------------------
// Data Members
//------------------------------------------
erb_trans erb_out;
erb_trans cloned_erb_out;
// position of frame within a multiframe
// 0 ~ K-1
int f_position;
// self generated octet position in a frame
// when CGS is still ongoing and IFS not finished yet 
// the layer should use self counting octet position to make 
// the layering continue to operate
// 0 ~ F-1
int self_o_position;
// Elastic RX Buffer, 1st index is position of frame in the buffer, 2nd index
// is octet position in a frame
erb m_erb;
rx_jesd204b_layering_config m_cfg;

//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(erb_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "cgs2erb_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void write(cgsnfs_trans t);

// Proxy Methods:
extern function void notify_transaction(erb_trans item);
// Helper Methods:

endclass: cgs2erb_monitor


function cgs2erb_monitor::new(string name = "cgs2erb_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction


function void cgs2erb_monitor::build_phase(uvm_phase phase);
    m_cfg = rx_jesd204b_layering_config::get_config(this);
    f_position = 0;
    self_o_position = 0;
    m_erb = new(m_cfg.erb_size, m_cfg.RBD);
    ap = new("ap", this);
endfunction: build_phase


function void cgs2erb_monitor::write(cgsnfs_trans t);
    int o_position;
    // before CGS is finished this layering should use self generated octet 
    // position to keep upper layering running
    if (t.ifsstate == FS_INIT) begin
        o_position = self_o_position;
    end else if (t.valid) begin
        o_position = t.o_position;
    end else begin
        o_position = o_position;
    end

    if (o_position == 0) begin
    // start of a frame, we create a new transaction to store a new frame
        `uvm_info("CGS2ERB Monitor", "Start of a new frame", UVM_HIGH)
        erb_out = erb_trans::type_id::create("erb_out");
        erb_out.data = new[m_cfg.F];
        erb_out.is_control_word = new[m_cfg.F];

        erb_out.data[o_position] = t.data;
        erb_out.is_control_word[o_position] = t.is_control_word;
        erb_out.f_position = f_position;
        erb_out.sync_request = t.sync_request;
        erb_out.valid = t.valid;
    end else begin
        assert(erb_out != null) begin
            erb_out.data[o_position] = t.data;
            erb_out.is_control_word[o_position] = t.is_control_word;
            erb_out.valid &= t.valid;

            if (o_position == (m_cfg.F-1)) begin
                // MSB should be the first octet ever received
                erb_out.data.reverse();
                erb_out.is_control_word.reverse();

                // tries to feed the frame into ERB
                if (m_erb.put(erb_out, t.ifsstate)) begin
                    `uvm_info("CGS2ERB Monitor", "Fed a new frame into ERB", 
                        UVM_MEDIUM)
                end

                if (m_erb.get(cloned_erb_out)) begin
                    `uvm_info("CGS2ERB Monitor", "Sending out a new frame", 
                        UVM_MEDIUM)
                    // Clone and publish the cloned item to the subscribers
                    notify_transaction(cloned_erb_out);
                end

                f_position = (f_position+1) % m_cfg.K;
            end
        end else begin
            $warning("Something went wrong with o_position");
        end
    end
    self_o_position = (self_o_position+1) % m_cfg.F;
endfunction


function void cgs2erb_monitor::notify_transaction(erb_trans item);
    ap.write(item);
endfunction : notify_transaction
