//
// Register test:
//
// Checks the reset values
// Does a randomized read/write bit test using the front door
//
class teset_streaming_legal_vseq extends test_vseq_base;

  `uvm_object_utils(teset_streaming_legal_vseq)

  function new(string name = "teset_streaming_legal_vseq");
    super.new(name);
  endfunction

  task body;
      enc_bus_valid_legal_sequence seq = enc_bus_valid_legal_sequence::type_id::
          create("seq");

    super.body;
    seq.start(enc_bus_sequencer_h);
  endtask: body

endclass: teset_streaming_legal_vseq
