// Class Description:
class test_base_long extends test_base;

// UVM Factory Registration Macro
//
`uvm_component_utils(test_base_long)

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
extern function new(string name = "test_base_long", 
uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task main_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

endclass: test_base_long

function test_base_long::new(string name = "test_base_long", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void test_base_long::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction: build_phase

task test_base_long::main_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this, "Test started");
    `uvm_info("TEST", "DUT reset completed", UVM_MEDIUM)
    #1us;
    phase.drop_objection(this, "Test finished");
endtask

function void test_base_long::report_phase(uvm_phase phase);
   uvm_coreservice_t cs_;
   uvm_report_server svr;

   cs_ = uvm_coreservice_t::get();
   svr = cs_.get_report_server();
//   svr = get_report_server();

   if(svr.get_severity_count(UVM_ERROR) == 0) begin
     `uvm_info("** UVM TEST PASSED **", "test passed \
     with no errors", UVM_LOW)
   end else begin
     `uvm_error("!! UVM TEST FAILED !!", "test failed")
   end

endfunction: report_phase
