class decoder_8b10b_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(decoder_8b10b_monitor);

// Virtual Interface
virtual decoder_8b10b_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
decoder_8b10b_agent_config m_cfg;
  
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(decoder_8b10b_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "decoder_8b10b_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
extern function void notify_transaction(decoder_8b10b_trans item);
// Helper Methods:

endclass: decoder_8b10b_monitor

function decoder_8b10b_monitor::new(string name = "decoder_8b10b_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void decoder_8b10b_monitor::build_phase(uvm_phase phase);
    ap = new("ap", this);
    m_cfg = decoder_8b10b_agent_config::get_config(this);
    m_bfm = m_cfg.mon_bfm;
    m_bfm.proxy = this;
endfunction: build_phase

task decoder_8b10b_monitor::run_phase(uvm_phase phase);
  m_bfm.run();
endtask: run_phase

function void decoder_8b10b_monitor::report_phase(uvm_phase phase);
endfunction: report_phase

function void decoder_8b10b_monitor::notify_transaction(
    decoder_8b10b_trans item);
    ap.write(item);
endfunction : notify_transaction
