//
// Class Description:
//
//
class enc_bus_sequencer extends uvm_sequencer#(enc_bus_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(enc_bus_sequencer)

// Standard UVM Methods:
extern function new(string name="enc_bus_sequencer", 
uvm_component parent = null);

endclass: enc_bus_sequencer

function enc_bus_sequencer::new(string name="enc_bus_sequencer", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction
