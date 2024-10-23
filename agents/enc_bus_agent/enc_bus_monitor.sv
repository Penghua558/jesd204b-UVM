class enc_bus_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(enc_bus_monitor);

// Virtual Interface
virtual enc_bus_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
enc_bus_agent_config m_cfg;
  
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(enc_bus_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "enc_bus_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
extern function void notify_transaction(enc_bus_trans item);
// Helper Methods:

endclass: enc_bus_monitor

function enc_bus_monitor::new(string name = "enc_bus_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void enc_bus_monitor::build_phase(uvm_phase phase);
    ap = new("ap", this);
    m_cfg = enc_bus_agent_config::get_config(this);
    m_bfm = m_cfg.mon_bfm;
    m_bfm.proxy = this;
endfunction: build_phase

task enc_bus_monitor::run_phase(uvm_phase phase);
  m_bfm.run();
endtask: run_phase

function void enc_bus_monitor::report_phase(uvm_phase phase);
endfunction: report_phase

function void enc_bus_monitor::notify_transaction(enc_bus_trans item);
    ap.write(item);
endfunction : notify_transaction
