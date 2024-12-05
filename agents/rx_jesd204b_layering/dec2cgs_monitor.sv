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

    cgs_out.cgsstate;
    cgs_out.ifsstate;
    cgs_out.sync_request;

    // test if input data is control word
    k_minus = k_8b_minus.find_index with (item == t.data);
    k_plus = k_8b_plus.find_index with (item == t.data);
    k_minus_size = k_minus.size();
    k_plus_size = k_plus.size();

    if (k_minus_size || k_plus_size) begin
    // data is a control word, so we don't test for data word anymore
        cgs_out.is_control_word = 1'b1;
        cgs_out.not_in_table_error = 1'b0;
        // decode data
        if (k_minus_size)
            cgs_out.data = k_minus.pop_front();
        else
            cgs_out.data = k_plus.pop_front();

        // check running disparity error
        if ((!rd && k_minus_size) || (rd && k_plus_size))
            cgs_out.disparity_error = 1'b0;
        else
            cgs_out.disparity_error = 1'b1;

        // update running disparity
        data_10b_unpacked = my_unpacked_10b_type'(t.data);
        if(!is_disparity_neutral(data_10b_unpacked))
            rd = ~rd;
    end else begin
    // data is not control word, we then test for data word
        cgs_out.is_control_word = 1'b0;

        b5_minus = d_5b_minus.find_index with (item == t.data[9:4]);
        b5_plus = d_5b_plus.find_index with (item == t.data[9:4]);
        b3_minus = d_3b_minus.find_index with (item == t.data[3:0]);
        b3_plus = d_3b_plus.find_index with (item == t.data[3:0]);
        b5_minus_size = b5_minus.size();
        b5_plus_size = b5_plus.size();
        b3_minus_size = b3_minus.size();
        b3_plus_size = b3_plus.size();

        // test if data is a data word
        if ((!b5_minus_size && !b5_plus_size) ||
            (!b3_minus_size && !b3_plus_size)) begin
            cgs_out.not_in_table_error = 1'b1;
            cgs_out.data = 8'b0;
        end else begin
            cgs_out.not_in_table_error = 1'b0;
        end

        // decode abcdei & check running disparity error
        if (b5_minus_size || b5_plus_size) begin
            if (b5_minus_size) begin
                cgs_out.data[4:0] = b5_minus.pop_front();
                if (rd && !b5_plus_size)
                    cgs_out.disparity_error = 1'b1;
            end else begin
                cgs_out.data[4:0] = b5_plus.pop_front();
                if (!rd && !b5_minus_size)
                    cgs_out.disparity_error = 1'b1;
            end
        end

        // update abcdei running disparity
        data_6b_unpacked = my_unpacked_6b_type'(t.data[9:4]);
        if(!is_disparity_neutral(data_6b_unpacked))
            rd = ~rd;

        // decode fghj & check running disparity error
        if (b3_minus_size || b3_plus_size) begin
            if (b3_minus_size) begin
                d_3b_temp = b3_minus.pop_front();

                // check alternate encode of D.x.7
                if (d_3b_temp == 4'd8)
                    cgs_out.data[7:5] = 3'd7;
                else
                    cgs_out.data[7:5] = d_3b_temp[2:0];

                // for D.x.7,
                // at running disparity of RD-, if x = 17, 18 or 20,
                // it must uses alternate encode, otherwise the code
                // received is not in table
                if ((cgs_out.data[4:0] == 17 ||
                    cgs_out.data[4:0] == 18 ||
                    cgs_out.data[4:0] == 20) &&
                    d_3b_temp == 4'd7) begin
                    cgs_out.not_in_table_error = 1'b1;
                end

                if (rd && !b3_plus_size)
                    cgs_out.disparity_error = 1'b1;
            end else begin
                d_3b_temp = b3_plus.pop_front();

                // check alternate encode of D.x.7
                if (d_3b_temp == 4'd8)
                    cgs_out.data[7:5] = 3'd7;
                else
                    cgs_out.data[7:5] = d_3b_temp[2:0];

                // for D.x.7,
                // at running disparity of RD+, if x = 11, 13 or 14,
                // it must uses alternate encode, otherwise the code
                // received is not in table
                if ((cgs_out.data[4:0] == 11 ||
                    cgs_out.data[4:0] == 13 ||
                    cgs_out.data[4:0] == 14) &&
                    d_3b_temp == 4'd7) begin
                    cgs_out.not_in_table_error = 1'b1;
                end

                if (!rd && !b3_minus_size)
                    cgs_out.disparity_error = 1'b1;
            end
        end

        // update fghj running disparity
        data_4b_unpacked = my_unpacked_4b_type'(t.data[3:0]);
        if(!is_disparity_neutral(data_4b_unpacked))
            rd = ~rd;

    cgs_out.sync_n = t.sync_n;

    // Clone and publish the cloned item to the subscribers
    $cast(cloned_cgs_out, cgs_out.clone());
    notify_transaction(cloned_cgs_out);
    end
endfunction


function void dec2cgs_monitor::notify_transaction(
    cgsnfs_trans item);
    ap.write(item);
endfunction : notify_transaction
