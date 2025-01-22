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
// which is LSB, which is the last sent out from transmitter
logic [7:0] data[];
bit is_control_word[];
// 1 - all octets in this frame are valid
// 0 - there is at least 1 octet in this frame is not valid
bit valid;
// position of frame within a multiframe
// 0 ~ K-1
int f_position;

// passed from lower layer
bit sync_request;

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
    valid = rhs_.valid;
    f_position = rhs_.f_position;
    sync_request = rhs_.sync_request;
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
      valid == rhs_.valid &&
      f_position == rhs_.f_position &&
      sync_request == rhs_.sync_request;
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
    printer.print_int("All octets valid?", valid, $bits(valid), UVM_BIN);
    printer.print_int("Frame position inside a multiframe", 
        f_position, $bits(f_position), UVM_DEC);
    printer.print_int("Sync request", 
        sync_request, $bits(sync_request), UVM_BIN);
endfunction:do_print


function void erb_trans::do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("erb_trans", this.sprint()) 
endfunction:do_record
