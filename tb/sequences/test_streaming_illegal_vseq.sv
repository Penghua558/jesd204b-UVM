//
// Register test:
//
// Checks the reset values
// Does a randomized read/write bit test using the front door
//
class test_streaming_illegal_vseq extends test_vseq_base;

  `uvm_object_utils(test_streaming_illegal_vseq)

  function new(string name = "test_streaming_illegal_vseq");
    super.new(name);
  endfunction

  task body;
      enc_bus_valid_illegal_sequence seq = enc_bus_valid_illegal_sequence::
          type_id::create("seq");

    super.body;
    fork
        forever begin
            seq.start(enc_bus_sequencer_h);
        end
        #2us;
    join_any
  endtask: body

endclass: test_streaming_illegal_vseq
