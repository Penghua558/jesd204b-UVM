//
// Class Description:
//
//
class erb_sequencer extends uvm_sequencer#(erb_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(erb_sequencer)

uvm_analysis_imp #(erb_trans, erb_sequencer) sequencer_export;
// intended to be used by ila2erb_seq, so ILA layering know how to drive FSM
erb_trans instruction_trans[$];

// Standard UVM Methods:
extern function new(string name="erb_sequencer", 
uvm_component parent = null);
extern virtual function void build_phase(uvm_phase phase);
extern virtual function void write(erb_trans t);

endclass: erb_sequencer


function erb_sequencer::new(string name="erb_sequencer", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction


function void erb_sequencer::build_phase(uvm_phase phase);
    sequencer_export = new("sequencer_export", this);
endfunction


function void erb_sequencer::write(erb_trans t);
    instruction_trans.push_back(t);
endfunction
