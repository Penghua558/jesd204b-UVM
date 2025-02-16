import global_dec::*;
class cgs2erb_monitor extends uvm_subscriber#(cgsnfs_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(cgs2erb_monitor);


//------------------------------------------
// Data Members
//------------------------------------------
erb_trans erb_out;
erb_trans adj_tr;
erb_trans cloned_erb_out;
// used to delay/advance LMFC and frame clock phase
erb_trans phase_adj_buffer[$];
// position of frame within a multiframe
// 0 ~ K-1
int f_position;
// self generated octet position in a frame
// when CGS is still ongoing and IFS not finished yet 
// the layer should use self counting octet position to make 
// the layering continue to operate
// 0 ~ F-1
int self_o_position;
// Number of adjustment clock period should the LMFC and frame clock should
// delay. In this agent, the adjustment clock is equal to frame clock
bit[3:0] ADJCNT;
bit valid_erb_out;
// Elastic RX Buffer, 1st index is position of frame in the buffer, 2nd index
// is octet position in a frame
elastic_rx_buffer m_elastic_rx_buffer;
rx_jesd204b_layering_config m_cfg;


//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(erb_trans) ap;
// 1 - frame is valid
// 0 - frame is invalid, at one octet within is invalid
bit frame_valid;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "cgs2erb_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void write(cgsnfs_trans t);
extern function void convert_adj2delay();


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
    frame_valid = 0;
    valid_erb_out = 1'b0;
    m_elastic_rx_buffer = new(m_cfg.erb_size, m_cfg.RBD);
    ap = new("ap", this);
endfunction: build_phase


function void cgs2erb_monitor::convert_adj2delay();
// Convert ADJCNT and ADJDIR in agent layering to delay phase adjustment,
// and assign the value to this monitor's ADJCNT
    if (!m_cfg.ADJDIR)
        this.ADJCNT = m_cfg.K - (m_cfg.ADJCNT % m_cfg.K);
    else
        this.ADJCNT = m_cfg.ADJCNT % m_cfg.K;
endfunction


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
        adj_tr = erb_trans::type_id::create("adj_tr");
        adj_tr.data = new[m_cfg.F];
        adj_tr.is_control_word = new[m_cfg.F];

        adj_tr.data[o_position] = t.data;
        adj_tr.is_control_word[o_position] = t.is_control_word;
        adj_tr.f_position = f_position;
        adj_tr.sync_request = t.sync_request;
        frame_valid = t.valid;
    end else begin
        assert(adj_tr != null) begin
            adj_tr.data[o_position] = t.data;
            adj_tr.is_control_word[o_position] = t.is_control_word;
            frame_valid &= t.valid;

            if (o_position == (m_cfg.F-1) && frame_valid) begin
                // only valid frames will be fed into Elastic RX Buffer
                // MSB should be the first octet ever received
                adj_tr.data.reverse();
                adj_tr.is_control_word.reverse();

                // Adjust LMFC and frame clock phase
                if (m_cfg.lmfc_adj_start) begin
                // convert all phase adjustment to delay phase
                    convert_adj2delay();
                    `uvm_info("CGS2ERB Monitor", 
                        $sformatf("Converted delay ADJCNT: %0d", this.ADJCNT), 
                        UVM_MEDIUM)
                    if (phase_adj_buffer.size() >= this.ADJCNT) begin
                        `uvm_info("CGS2ERB Monitor", 
                            "LMFC phase adjustment completed", UVM_MEDIUM)
                        m_cfg.lmfc_adj_start = 1'b0;
                        valid_erb_out = 1'b1;
                    end else
                        valid_erb_out = 1'b0;
                end

                phase_adj_buffer.push_back(adj_tr);

                if (!m_cfg.lmfc_adj_start)begin
                    erb_out = phase_adj_buffer.pop_front();
                end

                if (valid_erb_out) begin
                    // tries to feed the frame into ERB
                    if (m_elastic_rx_buffer.put(erb_out, t.ifsstate)) begin
                        `uvm_info("CGS2ERB Monitor", "Fed a frame into ERB", 
                            UVM_MEDIUM)
                    end
                end

                if (m_elastic_rx_buffer.get(cloned_erb_out)) begin
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
