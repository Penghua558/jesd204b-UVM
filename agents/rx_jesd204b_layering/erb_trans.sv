class erb_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(erb_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
// decoded data
// HGFEDCBA
// all incoming frames for transport layer only 
// contain data symbols
// first index will always stores the last incoming octet,
// which is LSB, which is sent out lastly from transmitter
byte unsigned data[];
bit is_control_word[];
// position of frame within a multiframe
// 0 ~ K-1
int f_position;

// passed from lower layer
bit sync_request;
// passed from upper layer during LMFC phase adjustment
// but it should be able to be set by any layers
bit err_report;
// 1 - this transaction is passthroughed from ERB, this happens when LMFC
// phase adjustment has not yet finished or not started.
// 0 - this transaction is a valid output of ERB.
//
// When this flag is 1, it tells upper layer this transaction does not 
// contain valid user data, but it does contain valid sync_request&err_report
// variables, so it enables lower layer to continue driving SYNC~.
//
// When this flag is 0, it tells upper layer this transaction contains valid
// user data.
bit erb_passthrough;

//------------------------------------------
// Constraints
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "erb_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:erb_trans


function erb_trans::new(string name = "erb_trans");
  super.new(name);
  this.erb_passthrough = 1'b0;
endfunction


function void erb_trans::do_copy(uvm_object rhs);
    erb_trans rhs_;

    if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
    end
    super.do_copy(rhs);
    // Copy over wdata members:
    data = rhs_.data;
    is_control_word = rhs_.is_control_word;
    f_position = rhs_.f_position;
    sync_request = rhs_.sync_request;
    err_report = rhs_.err_report;
    erb_passthrough = rhs_.erb_passthrough;
endfunction:do_copy


function bit erb_trans::do_compare(uvm_object rhs, 
    uvm_comparer comparer);
    erb_trans rhs_;

    if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
    end

    return super.do_compare(rhs, comparer) &&
      data == rhs_.data &&
      is_control_word == rhs_.is_control_word &&
      f_position == rhs_.f_position &&
      sync_request == rhs_.sync_request &&
      err_report == rhs_.err_report &&
      erb_passthrough == rhs_.erb_passthrough;
endfunction:do_compare


function void erb_trans::do_print(uvm_printer printer);
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
    printer.print_int("Sync request", 
        sync_request, $bits(sync_request), UVM_BIN);
    printer.print_int("ILA error report", 
        err_report, $bits(err_report), UVM_BIN);
    printer.print_string("Passthrough from ERB?", 
        (erb_passthrough)? "Yes":"No");
endfunction:do_print


function void erb_trans::do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("erb_trans", this.sprint()) 
endfunction:do_record
