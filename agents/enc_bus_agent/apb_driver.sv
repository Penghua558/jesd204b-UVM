class apb_driver extends uvm_driver #(apb_trans, apb_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_driver)

// Virtual Interface
virtual apb_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
apb_agent_config m_cfg;
  
//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "apb_driver", uvm_component parent = null);
extern task run_phase(uvm_phase phase);
extern function void build_phase(uvm_phase phase);

endclass: apb_driver

function apb_driver::new(string name = "apb_driver", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_cfg = apb_agent_config::get_config(this);
  m_bfm = m_cfg.drv_bfm;
  m_bfm.m_cfg = m_cfg;
  m_bfm.set_apb_index(m_cfg.apb_index);
endfunction: build_phase

task apb_driver::run_phase(uvm_phase phase);
    apb_trans req;

    m_bfm.reset();

    forever begin
        seq_item_port.get_next_item(req);
        m_bfm.drive(req);
        seq_item_port.item_done();
    end

endtask: run_phase
