class apb_recorder extends uvm_subscriber#(apb_trans);
    `uvm_component_utils(apb_recorder)

    uvm_text_tr_database tr_db;
    uvm_tr_stream tr_strm;
    uvm_recorder rec;

    function new( string name , uvm_component parent );
        super.new( name , parent );
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // tr_db = uvm_coreservice_t::get().get_default_tr_database();
        tr_db = uvm_text_tr_database::type_id::create("tr_db");
        tr_db.set_file_name("apb_trans.log");
        tr_strm = tr_db.open_stream("tr_strm");
        rec = tr_strm.open_recorder("rec");
    endfunction

    function void write(apb_trans t);
        `uvm_info("APB recorder", 
            "printing and recording transaction...", UVM_MEDIUM)
        t.print();
        t.record(rec);
    endfunction
endclass
