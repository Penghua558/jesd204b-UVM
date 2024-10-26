import enc_bus_dec::*;
class enc_bus_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(enc_bus_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
// HGFEDCBA, data intended to be encoded by RTL module
rand bit [7:0] data;
// 1 - data in this transaction should be processed by RTL module
// 0 - data in this transaction should be ignored by RTL module
rand bit valid;
// 1 - data in this transaction is a control word
// 0 - data in this transaction is a data word
rand bit control_word;
//------------------------------------------
// Constraints
//------------------------------------------

constraint control_word_legal_c {
    if (control_word) {
        data inside {K28_0, K28_1, K28_2, K28_3, K28_4, K28_5, K28_6, K28_7,
                    K23_7, K27_7, K29_7, K30_7};
    }
}

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "enc_bus_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:enc_bus_trans

function enc_bus_trans::new(string name = "enc_bus_trans");
  super.new(name);
endfunction

function void enc_bus_trans::do_copy(uvm_object rhs);
  enc_bus_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over wdata members:
  data = rhs_.data;
  valid = rhs_.valid;
  control_word = rhs_.control_word;

endfunction:do_copy

function bit enc_bus_trans::do_compare(uvm_object rhs, uvm_comparer comparer);
  enc_bus_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         data == rhs_.data &&
         valid == rhs_.valid &&
         control_word == rhs_.control_word;
endfunction:do_compare

function void enc_bus_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_int("Data", data, $bits(data), UVM_HEX);
    printer.print_string("Is data valid?", (valid)? "Yes":"No");
    printer.print_string("Is data a control word?", (control_word)? "Yes":"No");
endfunction:do_print

function void enc_bus_trans:: do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("enc_bus_trans", this.sprint()) 
endfunction:do_record
