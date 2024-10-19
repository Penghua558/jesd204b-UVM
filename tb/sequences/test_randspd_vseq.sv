//
// Register test:
//
// enable PMD901, then randomly write MOTORSPD register and BENDING register
//
class test_randspd_vseq extends test_vseq_base;

  `uvm_object_utils(test_randspd_vseq)

  function new(string name = "test_randspd_vseq");
    super.new(name);
  endfunction

  task body;
    enable_pmd901_sequence enable_seq = enable_pmd901_sequence::type_id::create(
        "enable_seq");
    rand_control_sequence rand_seq = rand_control_sequence::type_id::create(
        "rand_seq");
    apb_bus_seq_set_cfg(enable_seq);
    apb_bus_seq_set_cfg(rand_seq);
    
    super.body;
    enable_seq.start(m_sequencer);
    fork
        forever begin
            rand_seq.start(m_sequencer);
        end
        #200us;
    join_any
  endtask: body

endclass: test_randspd_vseq
