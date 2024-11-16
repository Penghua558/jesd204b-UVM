class deserializer_trans extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(deserializer_trans)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
// deserialized data
// abcdeifghj
logic [9:0] data;
// 1 - 8b10b symbol locked
// 0 - 8b10b symbol not locked
bit lock;


//------------------------------------------
// Constraints
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "deserializer_trans");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:deserializer_trans

function deserializer_trans::new(string name = "deserializer_trans");
  super.new(name);
  lock = 1'b0;
endfunction

function void deserializer_trans::do_copy(uvm_object rhs);
    deserializer_trans rhs_;

    if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
    end
    super.do_copy(rhs);
    // Copy over wdata members:
    data = rhs_.data;
    lock = rhs_.lock;
endfunction:do_copy

function bit deserializer_trans::do_compare(uvm_object rhs, 
    uvm_comparer comparer);
    deserializer_trans rhs_;

    if(!$cast(rhs_, rhs)) begin
        `uvm_error("do_copy", "cast of rhs object failed")
        return 0;
    end
    
    // if 8b10b symbol is locked, we care about the received data,
    // otherwise we don't care about the data since it's garbage anyway
    if (lock) begin
    return super.do_compare(rhs, comparer) &&
        data == rhs_.data &&
        lock == rhs_.lock;
    end else begin
    return super.do_compare(rhs, comparer) &&
        lock == rhs_.lock;
    end
endfunction:do_compare

function void deserializer_trans::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_int("Deserialized data", data, $bits(data), UVM_BIN);
    printer.print_string("Symbol locked?", (lock)? "Yes":"No");
endfunction:do_print

function void deserializer_trans:: do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_string("deserializer_trans", this.sprint()) 
endfunction:do_record
