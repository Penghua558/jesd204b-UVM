class cgsnfs2dec_seq extends uvm_sequence #(decoder_8b10b_trans);
    `uvm_object_utils(cgsnfs2dec_seq)

    uvm_sequencer #(cgsnfs_trans) up_sequencer;

    // Standard UVM Methods:
    extern function new(string name = "cgsnfs2dec_seq");
    extern task body;
endclass

function cgsnfs2dec_seq::new(string name = "cgsnfs2dec_seq");
    super.new(name);
endfunction

task cgsnfs2dec_seq::body;
    decoder_8b10b_trans dec_item;
    cgsnfs_trans cgsnfs_item;

    forever begin
        up_sequencer.get_next_item(cgsnfs_item);
        dec_item = decoder_8b10b_trans::type_id::create("dec_item");
        start_item(dec_item);
        dec_item.sync_n = cgsnfs_item.sync_n;
        finish_item(dec_item);
        up_sequencer.item_done();
    end
endtask
