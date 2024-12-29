import deser2dec_monitor_dec::*;
class deser2dec_monitor extends uvm_subscriber#(deserializer_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(deser2dec_monitor);

//------------------------------------------
// Data Members
//------------------------------------------
typedef bit my_unpacked_10b_type[10];
typedef bit my_unpacked_6b_type[6];
typedef bit my_unpacked_4b_type[4];
decoder_8b10b_trans dec_out;
decoder_8b10b_trans cloned_dec_out;
// running disparity
// 1 - RD+
// 0 - RD-
bit rd;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(decoder_8b10b_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "deser2dec_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void write(deserializer_trans t);
extern function bit is_disparity_neutral(bit data[]);

// Proxy Methods:
extern function void notify_transaction(decoder_8b10b_trans item);
// Helper Methods:

endclass: deser2dec_monitor

function deser2dec_monitor::new(string name = "deser2dec_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void deser2dec_monitor::build_phase(uvm_phase phase);
    ap = new("ap", this);
    rd = 1'b0;
endfunction: build_phase

function bit deser2dec_monitor::is_disparity_neutral(bit data[]);
    bit [3:0] num_ones;
    num_ones = data.sum() with(int'(item));
    if (num_ones == (data.size()/2))
        return 1'b1;
    else 
        return 1'b0;
endfunction

function void deser2dec_monitor::write(deserializer_trans t);
    `uvm_info("Received deserializer item", t.sprint(), UVM_MEDIUM)
    dec_out = decoder_8b10b_trans::type_id::create("dec_out");
    // if symbol is not locked then we don't need to process
    // deserializer_trans, since what it contains is garbage
    if (t.lock) begin

    byte k_minus[$];
    byte k_plus[$];
    int k_minus_size;
    int k_plus_size;
    bit [4:0] b5_minus[$];
    bit [4:0] b5_plus[$];
    bit [3:0] b3_minus[$];
    bit [3:0] b3_plus[$];
    int b5_minus_size;
    int b5_plus_size;
    int b3_minus_size;
    int b3_plus_size;
    bit [3:0] d_3b_temp;
    my_unpacked_10b_type data_10b_unpacked;
    my_unpacked_6b_type data_6b_unpacked;
    my_unpacked_4b_type data_4b_unpacked;


    dec_out.running_disparity = rd;
    dec_out.disparity_error = 1'b0;

    // test if input data is control word
    k_minus = k_8b_minus.find_index with (item == t.data);
    k_plus = k_8b_plus.find_index with (item == t.data);
    k_minus_size = k_minus.size();
    k_plus_size = k_plus.size();

    if (k_minus_size || k_plus_size) begin
    // data is a control word, so we don't test for data word anymore
        dec_out.is_control_word = 1'b1;
        dec_out.not_in_table_error = 1'b0;
        // decode data
        if (k_minus_size)
            dec_out.data = k_minus.pop_front();
        else
            dec_out.data = k_plus.pop_front();

        // check running disparity error
        if ((!rd && k_minus_size) || (rd && k_plus_size))
            dec_out.disparity_error = 1'b0;
        else
            dec_out.disparity_error = 1'b1;

        // update running disparity
        data_10b_unpacked = my_unpacked_10b_type'(t.data);
        if(!is_disparity_neutral(data_10b_unpacked))
            rd = ~rd;
    end else begin
    // data is not control word, we then test for data word
        dec_out.is_control_word = 1'b0;

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
            dec_out.not_in_table_error = 1'b1;
            dec_out.data = 8'b0;
        end else begin
            dec_out.not_in_table_error = 1'b0;
        end

        // decode abcdei & check running disparity error
        if (b5_minus_size || b5_plus_size) begin
            if (b5_minus_size) begin
                dec_out.data[4:0] = b5_minus.pop_front();
                if (rd && !b5_plus_size)
                    dec_out.disparity_error = 1'b1;
            end else begin
                dec_out.data[4:0] = b5_plus.pop_front();
                if (!rd && !b5_minus_size)
                    dec_out.disparity_error = 1'b1;
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
                    dec_out.data[7:5] = 3'd7;
                else
                    dec_out.data[7:5] = d_3b_temp[2:0];

                // for D.x.7,
                // at running disparity of RD-, if x = 17, 18 or 20,
                // it must uses alternate encode, otherwise the code
                // received is not in table
                if ((dec_out.data[4:0] == 17 ||
                    dec_out.data[4:0] == 18 ||
                    dec_out.data[4:0] == 20) &&
                    d_3b_temp == 4'd7) begin
                    dec_out.not_in_table_error = 1'b1;
                end

                if (rd && !b3_plus_size)
                    dec_out.disparity_error = 1'b1;
            end else begin
                d_3b_temp = b3_plus.pop_front();

                // check alternate encode of D.x.7
                if (d_3b_temp == 4'd8)
                    dec_out.data[7:5] = 3'd7;
                else
                    dec_out.data[7:5] = d_3b_temp[2:0];

                // for D.x.7,
                // at running disparity of RD+, if x = 11, 13 or 14,
                // it must uses alternate encode, otherwise the code
                // received is not in table
                if ((dec_out.data[4:0] == 11 ||
                    dec_out.data[4:0] == 13 ||
                    dec_out.data[4:0] == 14) &&
                    d_3b_temp == 4'd7) begin
                    dec_out.not_in_table_error = 1'b1;
                end

                if (!rd && !b3_minus_size)
                    dec_out.disparity_error = 1'b1;
            end
        end

        // update fghj running disparity
        data_4b_unpacked = my_unpacked_4b_type'(t.data[3:0]);
        if(!is_disparity_neutral(data_4b_unpacked))
            rd = ~rd;
    end

    dec_out.sync_n = t.sync_n;
    end

    // Clone and publish the cloned item to the subscribers
    $cast(cloned_dec_out, dec_out.clone());
    notify_transaction(cloned_dec_out);
endfunction


function void deser2dec_monitor::notify_transaction(
    decoder_8b10b_trans item);
    ap.write(item);
endfunction : notify_transaction
