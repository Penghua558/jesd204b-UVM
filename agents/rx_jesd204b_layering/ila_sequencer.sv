//
// Class Description:
//
//
class ila_sequencer extends uvm_sequencer#(ila_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(ila_sequencer)

// Standard UVM Methods:
extern function new(string name="ila_sequencer", 
uvm_component parent = null);

endclass: ila_sequencer

function ila_sequencer::new(string name="ila_sequencer", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction
