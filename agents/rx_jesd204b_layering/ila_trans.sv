import erb2ila_dec::*;
class ila_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(ila_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
// decoded data
// HGFEDCBA
// all incoming frames for transport layer only 
// contain data symbols
// first index will always stores the last incoming octet,
// which is LSB, which is the last sent out from transmitter
byte unsigned data[];
bit is_control_word[];
// position of frame within a multiframe
// 0 ~ K-1
int f_position;

// current ILA statemachine state
erb2ila_dec::ilastate_e ilastate;
// report error at last stage during LMFC phase adjustment
// normally it would not be randomized as it can be completely driven by
// protocol, but to make error report easier to generate we would to randomize
// it directly rather than creating errors which would trigger error report
rand bit err_report;

//------------------------------------------
// Constraints
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "ila_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:ila_trans


function ila_trans::new(string name = "ila_trans");
  super.new(name);
endfunction


function void ila_trans::do_copy(uvm_object rhs);
    ila_trans rhs_;

    if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
    end
    super.do_copy(rhs);
    // Copy over wdata members:
    data = rhs_.data;
    is_control_word = rhs_.is_control_word;
    f_position = rhs_.f_position;
    err_report = rhs_.err_report;
endfunction:do_copy


function bit ila_trans::do_compare(uvm_object rhs, 
    uvm_comparer comparer);
    ila_trans rhs_;

    if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
    end

    return super.do_compare(rhs, comparer) &&
      data == rhs_.data &&
      is_control_word == rhs_.is_control_word &&
      f_position == rhs_.f_position &&
      err_report == rhs_.err_report;
endfunction:do_compare


function void ila_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    if (data.size) begin
        foreach(data[i]) begin
            printer.print_int($sformatf("Decoded frame[%0d]", i), 
                data[i], $bits(data[i]), UVM_HEX);
        end
    end else begin
        printer.print_string("Decoded frame", "No data");
    end

    if (is_control_word.size) begin
        foreach(is_control_word[i]) begin
            printer.print_string($sformatf("Is control word[%0d]?", i), 
                (is_control_word[i])? "Yes":"No");
        end
    end else begin
        printer.print_string("Is control word?", "No data");
    end
    printer.print_int("Frame position inside a multiframe", 
        f_position, $bits(f_position), UVM_DEC);
    printer.print_int("ILA error report", 
        err_report, $bits(err_report), UVM_DEC);
endfunction:do_print


function void ila_trans::do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("ila_trans", this.sprint()) 
endfunction:do_record
