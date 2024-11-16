class deserializer_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(deserializer_monitor);

// Virtual Interface
virtual deserializer_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
deserializer_agent_config m_cfg;
  
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(deserializer_trans) ap;
time time_locked[$];

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "deserializer_monitor", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
extern function void notify_transaction(deserializer_trans item);
// Helper Methods:

endclass: deserializer_monitor

function deserializer_monitor::new(string name = "deserializer_monitor", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void deserializer_monitor::build_phase(uvm_phase phase);
    ap = new("ap", this);
    m_cfg = deserializer_agent_config::get_config(this);
    m_bfm = m_cfg.mon_bfm;
    m_bfm.proxy = this;
    m_bfm.m_cfg = m_cfg;
endfunction: build_phase

task deserializer_monitor::run_phase(uvm_phase phase);
    fork
        m_bfm.run();
        begin
            @(posedge m_bfm.lock);
            time_locked.push_back($time);
        end
    join_none
endtask: run_phase

function void deserializer_monitor::notify_transaction(
    deserializer_trans item);
    ap.write(item);
endfunction : notify_transaction

function void deserializer_monitor::report_phase(uvm_phase phase);
    super.report_phase(phase);
    while(time_locked.size()) begin
        `uvm_info("Deserialized Monitor", 
            $sformatf("At time %t symbol is locked", 
            time_locked.pop_front()), UVM_LOW)
    end
endfunction
