class enc_bus_driver extends uvm_driver #(enc_bus_trans, enc_bus_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(enc_bus_driver)

// Virtual Interface
virtual enc_bus_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
enc_bus_agent_config m_cfg;
  
//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "enc_bus_driver", 
uvm_component parent = null);
extern task run_phase(uvm_phase phase);
extern function void build_phase(uvm_phase phase);

endclass: enc_bus_driver

function enc_bus_driver::new(string name = "enc_bus_driver", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void enc_bus_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_cfg = enc_bus_agent_config::get_config(this);
  m_bfm = m_cfg.drv_bfm;
  m_bfm.m_cfg = m_cfg;
endfunction: build_phase

task enc_bus_driver::run_phase(uvm_phase phase);
    enc_bus_trans req;

    m_bfm.reset();

    forever begin
        seq_item_port.get_next_item(req);
        m_bfm.drive(req);
        seq_item_port.item_done();
    end

endtask: run_phase
