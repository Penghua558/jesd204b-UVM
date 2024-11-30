class dec8b10b2des_seq extends uvm_sequence #(deserializer_trans);
    `uvm_object_utils(dec8b10b2des_seq)

    uvm_sequencer #(decoder_8b10b_trans) up_sequencer;

    // Standard UVM Methods:
    extern function new(string name = "dec8b10b2des_seq");
    extern task body;
endclass

function dec8b10b2des_seq::new(string name = "dec8b10b2des_seq");
    super.new(name);
endfunction

task dec8b10b2des_seq::body;
    deserializer_trans deser_item;
    decoder_8b10b_trans dec_item;

    forever begin
        up_sequencer.get_next_item(dec_item);
        deser_item = deserializer_trans::type_id::create("deser_item");
        start_item(deser_item);
        deser_item.sync_n = dec_item.sync_n;
        finish_item(deser_item);
        up_sequencer.item_done();
    end
endtask
