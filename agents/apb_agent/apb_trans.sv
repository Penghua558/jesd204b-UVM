import apb_agent_dec::*;
class apb_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
rand logic[15:0] addr;
rand logic[15:0] wdata;
rand op_e wr;
rand int delay;

logic [15:0] rdata;

//------------------------------------------
// Constraints
//------------------------------------------

constraint delay_bounds {
  delay inside {[1:20]};
}

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:apb_trans

function apb_trans::new(string name = "apb_trans");
  super.new(name);
endfunction

function void apb_trans::do_copy(uvm_object rhs);
  apb_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over wdata members:
  addr = rhs_.addr;
  wdata = rhs_.wdata;
  wr = rhs_.wr;
  delay = rhs_.delay;
  rdata = rhs_.rdata;

endfunction:do_copy

function bit apb_trans::do_compare(uvm_object rhs, uvm_comparer comparer);
  apb_trans rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         addr == rhs_.addr &&
         wdata == rhs_.wdata &&
         wr   == rhs_.wdata &&
         rdata == rhs_.rdata;
  // Delay is not relevant to the comparison
endfunction:do_compare

function void apb_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_int("Address", addr, $bits(addr), UVM_HEX);
    printer.print_string("Operation", wr.name());
    printer.print_int("Write data", wdata, $bits(wdata), UVM_HEX);
    printer.print_int("Read data", rdata, $bits(rdata), UVM_HEX);
    printer.print_int("Delay before transaction", delay, $bits(delay), UVM_DEC);
endfunction:do_print

function void apb_trans:: do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("apb_trans", this.sprint()) 
endfunction:do_record
