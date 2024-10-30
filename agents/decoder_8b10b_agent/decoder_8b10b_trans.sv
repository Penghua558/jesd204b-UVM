class decoder_8b10b_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(decoder_8b10b_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
// decoded data
// HGFEDCBA
logic [7:0] data;
logic is_control_word;
// running disparity used to decode in this transaction
// 1 - RD+
// 0 - RD-
logic running_disparity;
// it's a valid character, however running disparity is wrong
logic disparity_error;
logic k_not_valid_error;
// not a control word nor a data word
logic not_in_table_error;


//------------------------------------------
// Constraints
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "decoder_8b10b_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:decoder_8b10b_trans

function decoder_8b10b_trans::new(string name = "decoder_8b10b_trans");
  super.new(name);
endfunction

function void decoder_8b10b_trans::do_copy(uvm_object rhs);
  decoder_8b10b_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over wdata members:
  data = rhs_.data;
  is_control_word = rhs_.is_control_word;
  running_disparity = rhs_.running_disparity;
  disparity_error = rhs_.disparity_error;
  k_not_valid_error = rhs_.k_not_valid_error;
  not_in_table_error = rhs_.not_in_table_error;

endfunction:do_copy

function bit decoder_8b10b_trans::do_compare(uvm_object rhs, 
    uvm_comparer comparer);
  decoder_8b10b_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end

    // if received character is not in table, then we don't care whether we
    // decoded the character correctly or not
    if (not_in_table_error) begin
    return super.do_compare(rhs, comparer) &&
         disparity_error == rhs_.disparity_error &&
         running_disparity == rhs_.running_disparity &&
         k_not_valid_error == rhs_.k_not_valid_error &&
         is_control_word == rhs_.is_control_word &&
         not_in_table_error == rhs_.not_in_table_error;
    end else begin
    return super.do_compare(rhs, comparer) &&
        data == rhs_.data &&
        disparity_error == rhs_.disparity_error &&
        running_disparity == rhs_.running_disparity &&
        k_not_valid_error == rhs_.k_not_valid_error &&
        is_control_word == rhs_.is_control_word &&
        not_in_table_error == rhs_.not_in_table_error;
    end
endfunction:do_compare

function void decoder_8b10b_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_int("Decoded data", data, $bits(data), UVM_HEX);
    printer.print_string("Is control word?", (is_control_word)? "Yes":"No");
    printer.print_string("Running disparity", (running_disparity)? "RD+":"RD-");
    printer.print_int("Disparity error", disparity_error, 
        $bits(disparity_error), UVM_BIN);
    printer.print_int("k not valid error", k_not_valid_error, 
        $bits(k_not_valid_error), UVM_BIN);
    printer.print_int("Not in table error", not_in_table_error, 
        $bits(not_in_table_error), UVM_BIN);
endfunction:do_print

function void decoder_8b10b_trans:: do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("decoder_8b10b_trans", this.sprint()) 
endfunction:do_record
