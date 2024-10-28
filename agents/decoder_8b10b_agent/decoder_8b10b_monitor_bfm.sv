//
// BFM Interface Description:
//
//
interface decoder_8b10b_monitor_bfm (
    input clk,
    input rst_n,

    // abcdeifghj
    input logic [9:0] data,
    input k_error
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import decoder_8b10b_agent_dec::*;
import decoder_8b10b_agent_pkg::*;

typedef bit my_unpacked_10b_type[10];
typedef bit my_unpacked_6b_type[6];
typedef bit my_unpacked_4b_type[4];


//------------------------------------------
// Data Members
//------------------------------------------
decoder_8b10b_monitor proxy;
// running disparity
// 1 - RD+
// 0 - RD-
bit rd;

//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
task automatic wait_for_reset();
    @(posedge rst_n);
    rd = 1'b0;
    @(posedge clk);
endtask

function bit is_disparity_neutral(bit data[]);
    bit [3:0] num_ones;
    num_ones = data.sum() with(int'(item));
    if (num_ones == (data.size()/2))
        return 1'b1;
    else 
        return 1'b0;
endfunction

// BFM Methods:
task run();
    decoder_8b10b_trans item;
    decoder_8b10b_trans cloned_item;
    byte k_minus[$];
    byte k_plus[$];
    int k_minus_size;
    int k_plus_size;
    bit [4:0] b5_minus[$];
    bit [4:0] b5_plus[$];
    bit [2:0] b3_minus[$];
    bit [2:0] b3_plus[$];
    int b5_minus_size;
    int b5_plus_size;
    int b3_minus_size;
    int b3_plus_size;
    my_unpacked_10b_type data_10b_unpacked;
    my_unpacked_6b_type data_6b_unpacked;
    my_unpacked_4b_type data_4b_unpacked;

    item = decoder_8b10b_trans::type_id::create("item");

    forever begin
        k_minus.delete();
        k_plus.delete();
        b5_minus.delete();
        b5_plus.delete();
        b3_minus.delete();
        b3_plus.delete();
        @(posedge clk);
        item.running_disparity = rd;
        item.k_not_valid_error = k_error;

        // test if input data is control word
        k_minus = k_8b_minus.find_index with (item == data);
        k_plus = k_8b_plus.find_index with (item == data);
        k_minus_size = k_minus.size();
        k_plus_size = k_plus.size();

        if (k_minus_size || k_plus_size) begin
        // data is a control word, so we don't test for data word anymore
            item.is_control_word = 1'b1;
            item.not_in_table_error = 1'b0;
            // decode data
            if (k_minus_size)
                item.data = k_minus.pop_front();
            else
                item.data = k_plus.pop_front();

            // check running disparity error
            if ((!rd && k_minus_size) || (rd && k_plus_size))
                item.disparity_error = 1'b0;
            else
                item.disparity_error = 1'b1;

            // update running disparity
            data_10b_unpacked = my_unpacked_10b_type'(data);
            if(!is_disparity_neutral(data_10b_unpacked))
                rd = ~rd;
        end else begin
        // data is not control word, we then test for data word
            item.is_control_word = 1'b0;

            b5_minus = d_5b_minus.find_index with (item == data[9:4]);
            b5_plus = d_5b_plus.find_index with (item == data[9:4]);
            b3_minus = d_3b_minus.find_index with (item == data[3:0]);
            b3_plus = d_3b_plus.find_index with (item == data[3:0]);
            b5_minus_size = b5_minus.size();
            b5_plus_size = b5_plus.size();
            b3_minus_size = b3_minus.size();
            b3_plus_size = b3_plus.size();

            // test if data is a data word
            if ((!b5_minus_size && !b5_plus_size) ||
                (!b3_minus_size && !b3_plus_size)) begin
                item.not_in_table_error = 1'b1;
                item.data = 8'b0;
            end else begin
                item.not_in_table_error = 1'b0;
            end

            // decode abcdei
            if (b5_minus_size || b5_plus_size) begin
                if (b5_minus_size)
                    item.data[4:0] = b5_minus.pop_front();
                else
                    item.data[4:0] = b5_plus.pop_front();
            end

            // decode fghj
            if (b3_minus_size || b3_plus_size) begin
                if (b3_minus_size)
                    item.data[7:5] = b3_minus.pop_front();
                else
                    item.data[7:5] = b3_plus.pop_front();
            end

            item.disparity_error = 1'b0;
            // check&update abcedi running disparity
            if ((!rd && b5_plus_size) || (rd && b5_minus_size)) begin
                item.disparity_error = 1'b1;
            end
            data_6b_unpacked = my_unpacked_6b_type'(data[9:4]);
            if(!is_disparity_neutral(data_6b_unpacked))
                rd = ~rd;

            // check&update fghj running disparity
            if ((!rd && b3_plus_size) || (rd && b3_minus_size)) begin
                item.disparity_error = 1'b1;
            end
            data_4b_unpacked = my_unpacked_4b_type'(data[3:0]);
            if(!is_disparity_neutral(data_4b_unpacked))
                rd = ~rd;
        end

        // Clone and publish the cloned item to the subscribers
        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask: run

endinterface: decoder_8b10b_monitor_bfm
