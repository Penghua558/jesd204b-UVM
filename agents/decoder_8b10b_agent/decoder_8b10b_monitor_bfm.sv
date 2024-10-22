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
    bit [7:0] k_minus[$];
    bit [7:0] k_plus[$];
    int k_minus_size;
    int k_plus_size;
    bit [4:0] 5b_minus[$];
    bit [4:0] 5b_plus[$];
    bit [2:0] 3b_minus[$];
    bit [2:0] 3b_plus[$];
    int 5b_minus_size;
    int 5b_plus_size;
    int 3b_minus_size;
    int 3b_plus_size;
    my_unpacked_10b_type data_10b_unpacked;
    my_unpacked_6b_type data_6b_unpacked;
    my_unpacked_4b_type data_4b_unpacked;

    item = decoder_8b10b_trans::type_id::create("item");

    forever begin
        k_minus.delete();
        k_plus.delete();
        5b_minus.delete();
        5b_plus.delete();
        3b_minus.delete();
        3b_plus.delete();
        @(posedge clk);
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

            5b_minus = d_5b_minus.find_index with (item == data[9:4]);
            5b_plus = d_5b_plus.find_index with (item == data[9:4]);
            3b_minus = d_3b_minus.find_index with (item == data[3:0]);
            3b_plus = d_3b_plus.find_index with (item == data[3:0]);
            5b_minus_size = 5b_minus.size();
            5b_plus_size = 5b_plus.size();
            3b_minus_size = 3b_minus.size();
            3b_plus_size = 3b_plus.size();

            // test if data is a data word
            if ((!5b_minus_size && !5b_plus_size) ||
                (!3b_minus_size && !3b_plus_size)) begin
                item.not_in_table_error = 1'b1;
                item.data = 8'b0;
            end else begin
                item.not_in_table_error = 1'b0;
            end

            // decode abcdei
            if (5b_minus_size || 5b_plus_size) begin
                if (5b_minus_size)
                    item.data[4:0] = 5b_minus.pop_front();
                else
                    item.data[4:0] = 5b_plus.pop_front();
            end

            // decode fghj
            if (3b_minus_size || 3b_plus_size) begin
                if (3b_minus_size)
                    item.data[7:5] = 3b_minus.pop_front();
                else
                    item.data[7:5] = 3b_plus.pop_front();
            end

            item.disparity_error = 1'b0;
            // check&update abcedi running disparity
            if ((!rd && 5b_plus_size) || (rd && 5b_minus_size)) begin
                item.disparity_error = 1'b1;
            end
            data_6b_unpacked = my_unpacked_6b_type'(data[9:4]);
            if(!is_disparity_neutral(data_6b_unpacked))
                rd = ~rd;

            // check&update fghj running disparity
            if ((!rd && 3b_plus_size) || (rd && 3b_minus_size)) begin
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
