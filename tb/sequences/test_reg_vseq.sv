//
// Register test:
//
// Checks the reset values
// Does a randomized read/write bit test using the front door
//
class test_reg_vseq extends test_vseq_base;

  `uvm_object_utils(test_reg_vseq)

  function new(string name = "test_reg_vseq");
    super.new(name);
  endfunction

  task body;
    uvm_reg_hw_reset_seq rst_seq = uvm_reg_hw_reset_seq::type_id::create(
        "rst_seq");
    uvm_reg_bit_bash_seq bash_seq = uvm_reg_bit_bash_seq::type_id::create(
        "bash_seq");
    rst_seq.model = m_cfg.spi_rb;
    bash_seq.model = m_cfg.spi_rb;

    super.body;
    // register reset value test
    rst_seq.start(m_sequencer);
    // register read/write test
    bash_seq.start(m_sequencer);
  endtask: body

endclass: test_reg_vseq
