import apb_agent_dec::*;
class decoder_8b10b_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(decoder_8b10b_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
logic [7:0] data;
logic k_not_valid_error;


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
  k_not_valid_error = rhs_.k_not_valid_error;

endfunction:do_copy

function bit decoder_8b10b_trans::do_compare(uvm_object rhs, 
    uvm_comparer comparer);
  decoder_8b10b_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         data == rhs_.data&&
         k_not_valid_error == rhs_.k_not_valid_error;
endfunction:do_compare

function void decoder_8b10b_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_int("Decoded data", data, $bits(data), UVM_HEX);
    printer.print_int("k not valid error", k_not_valid_error, 
        $bits(k_not_valid_error), UVM_BIN);
endfunction:do_print

function void decoder_8b10b_trans:: do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("decoder_8b10b_trans", this.sprint()) 
endfunction:do_record
