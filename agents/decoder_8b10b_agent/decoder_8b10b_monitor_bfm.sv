//
// BFM Interface Description:
//
//
interface decoder_8b10b_monitor_bfm (
  input clk,
  input rst_n,

  input logic [9:0] data,
  input k_error
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import decoder_8b10b_agent_dec::*;
import decoder_8b10b_agent_pkg::*;

typedef bit my_unpacked_10b_type[10];


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
    my_unpacked_10b_type data_10b_unpacked;

    item = decoder_8b10b_trans::type_id::create("item");

    forever begin
        k_minus.delete();
        k_plus.delete();
        @(posedge clk);
        item.k_not_valid_error = k_error;

        // test if input data is control word
        k_minus = k_8b_minus.find_index with (item == data);
        k_plus = k_8b_plus.find_index with (item == data);
        k_minus_size = k_minus.size();
        k_plus_size = k_plus.size();

        if (k_minus_size || k_plus_size) begin
            item.is_control_word = 1'b1;
            if ((!rd && k_minus_size) || (rd && k_plus_size))
                item.disparity_error = 1'b0;
            else
                item.disparity_error = 1'b1;
            // update running disparity
            data_10b_unpacked = my_unpacked_10b_type'(data);
            if(!is_disparity_neutral(data_10b_unpacked))
                rd = ~rd;
        end

        // Clone and publish the cloned item to the subscribers
        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask: run

endinterface: decoder_8b10b_monitor_bfm
