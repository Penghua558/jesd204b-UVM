import cgsnfs_dec::*;
class cgsnfs_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(cgsnfs_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
// decoded data
// HGFEDCBA
logic [7:0] data;
bit is_control_word;
// position of octet within a frame
// 0 ~ F-1
int o_position;

// 1 - It is a valid word given current running disparity
// 0 - invalid word, due to wrong running disparity or not in table error
// valid = !(disparity_error || not_in_table_error)
bit valid;

// current CGS statemachine state
cgsstate_e cgsstate;

// current Initial frame synchronization statemachine state
ifsstate_e ifsstate;

// 1 - to assert SYNC~
// 0 - to de-assert SYNC~
// however, sync_request is not the only signal driving SYNC~
// SYNC~ = !(sync_request || time since last sync_request assertion < 5 frames
// + 9 octets)
bit sync_request;

rand logic sync_n;

//------------------------------------------
// Constraints
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "cgsnfs_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:cgsnfs_trans

function cgsnfs_trans::new(string name = "cgsnfs_trans");
  super.new(name);
endfunction

function void cgsnfs_trans::do_copy(uvm_object rhs);
  cgsnfs_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over wdata members:
  data = rhs_.data;
  is_control_word = rhs_.is_control_word;
  o_position == rhs_.o_position;
  valid = rhs_.valid;
  cgsstate = rhs_.cgsstate;
  ifsstate = rhs_.ifsstate;
  sync_request = rhs_.sync_request;
  sync_n = rhs_.sync_n;
endfunction:do_copy

function bit cgsnfs_trans::do_compare(uvm_object rhs, 
    uvm_comparer comparer);
  cgsnfs_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end

    // if received character is not in table or it's an invalid contro word, 
    // then we don't care whether we decoded the character correctly or not
    if (valid) begin
    return super.do_compare(rhs, comparer) &&
        data == rhs_.data &&
        is_control_word == rhs_.is_control_word &&
        o_position == rhs_.o_position &&
        valid == rhs_.valid &&
        cgsstate == rhs_.cgsstate &&
        ifsstate == rhs_.ifsstate &&
        sync_request == rhs_.sync_request &&
        sync_n == rhs_.sync_n;
    end else begin
    return super.do_compare(rhs, comparer) &&
        is_control_word == rhs_.is_control_word &&
        o_position == rhs_.o_position &&
        valid == rhs_.valid &&
        cgsstate == rhs_.cgsstate &&
        ifsstate == rhs_.ifsstate &&
        sync_request == rhs_.sync_request &&
        sync_n == rhs_.sync_n;
    end
endfunction:do_compare

function void cgsnfs_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_int("Decoded data", data, $bits(data), UVM_HEX);
    printer.print_string("Is control word?", (is_control_word)? "Yes":"No");
    printer.print_int("Octet position", o_position, $bits(o_position), UVM_DEC);
    printer.print_string("Valid word?", (valid)? "Yes":"No");
    printer.print_string("CGS state", cgsstate.name());
    printer.print_string("IFS state", ifsstate.name());
    printer.print_int("sync request", sync_request, $bits(sync_request), 
        UVM_BIN);
    printer.print_int("SYNC~", sync_n, $bits(sync_n), UVM_BIN);
endfunction:do_print

function void cgsnfs_trans::do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("cgsnfs_trans", this.sprint()) 
endfunction:do_record
