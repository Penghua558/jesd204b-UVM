class apb_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_monitor);

// Virtual Interface
virtual apb_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
apb_agent_config m_cfg;
  
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(apb_trans) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "apb_monitor", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
extern function void notify_transaction(apb_trans item);
// Helper Methods:

endclass: apb_monitor

function apb_monitor::new(string name = "apb_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_monitor::build_phase(uvm_phase phase);
    ap = new("ap", this);
    m_cfg = apb_agent_config::get_config(this);
    m_bfm = m_cfg.mon_bfm;
    m_bfm.set_apb_index(m_cfg.apb_index);
    m_bfm.proxy = this;
endfunction: build_phase

task apb_monitor::run_phase(uvm_phase phase);
  m_bfm.run();
endtask: run_phase

function void apb_monitor::report_phase(uvm_phase phase);
endfunction: report_phase

function void apb_monitor::notify_transaction(apb_trans item);
    ap.write(item);
endfunction : notify_transaction
