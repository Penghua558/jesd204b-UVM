class deserializer_driver extends uvm_driver #(deserializer_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(deserializer_driver)

// Virtual Interface
virtual deserializer_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
deserializer_agent_config m_cfg;
  
//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "deserializer_driver", 
uvm_component parent = null);
extern task run_phase(uvm_phase phase);
extern function void build_phase(uvm_phase phase);

endclass: deserializer_driver

function deserializer_driver::new(string name = "deserializer_driver", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void deserializer_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_cfg = deserializer_agent_config::get_config(this);
  m_bfm = m_cfg.drv_bfm;
  m_bfm.m_cfg = m_cfg;
endfunction: build_phase

task deserializer_driver::run_phase(uvm_phase phase);
    deserializer_trans req;

    m_bfm.reset();

    forever begin
        seq_item_port.get_next_item(req);
        m_bfm.drive(req);
        seq_item_port.item_done();
    end

endtask: run_phase
