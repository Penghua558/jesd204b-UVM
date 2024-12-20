class test_vseq_base extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(test_vseq_base)

  function new(string name = "test_vseq_base");
    super.new(name);
  endfunction

  // Virtual sequencer handles
  enc_bus_sequencer enc_bus_sequencer_h;

  // Handle for env config to get to interrupt line
  env_config m_cfg;

  // This set up is required for child sequences to run
  task body;
    if(enc_bus_sequencer_h==null) begin
      `uvm_fatal("SEQ_ERROR", "Encoder bus sequencer handle is null")
    end

    if(m_cfg==null) begin
      `uvm_fatal("CFG_ERROR", "Configuration handle is null")
    end
  endtask: body
endclass: test_vseq_base
