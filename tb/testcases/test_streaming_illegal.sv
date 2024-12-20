// Class Description:
class test_streaming_illegal extends test_base;

// UVM Factory Registration Macro
//
`uvm_component_utils(test_streaming_illegal)

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "test_streaming_illegal", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

endclass: test_streaming_illegal

function test_streaming_illegal::new(string name = "test_streaming_illegal", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void test_streaming_illegal::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction: build_phase

task test_streaming_illegal::main_phase(uvm_phase phase);
    test_streaming_illegal_vseq t_seq = test_streaming_illegal_vseq::type_id::
        create("t_seq");
    set_sequencers(t_seq);

    super.run_phase(phase);
    phase.raise_objection(this, "Test started");
    m_env_cfg.wait_for_reset();
    `uvm_info("TEST", "DUT reset completed", UVM_MEDIUM)
    t_seq.start(null);
    #100ns;
    phase.drop_objection(this, "Test finished");
endtask

function void test_streaming_illegal::report_phase(uvm_phase phase);
   uvm_coreservice_t cs_;
   uvm_report_server svr;

   cs_ = uvm_coreservice_t::get();
   svr = cs_.get_report_server();
//   svr = get_report_server();

   if(svr.get_severity_count(UVM_ERROR) == 0) begin
     `uvm_info("** UVM TEST PASSED **", "SPI Register/reset test passed \
     with no errors", UVM_LOW)
   end else begin
     `uvm_error("!! UVM TEST FAILED !!", "SPI Register/reset test failed")
   end

endfunction: report_phase
