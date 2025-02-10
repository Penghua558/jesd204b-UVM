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
extern virtual function void build_phase(uvm_phase phase);

endclass: ila_sequencer

function ila_sequencer::new(string name="ila_sequencer", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void ila_sequencer::build_phase(uvm_phase phase);
    sequencer_export = new("sequencer_export", this);
endfunction
