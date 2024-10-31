class enc_8b10b_scoreboard extends uvm_component;

`uvm_component_utils(enc_8b10b_scoreboard)

dec_predictor predictor;
inorder_comparator#(decoder_8b10b_trans) evaluator;

uvm_analysis_export#(enc_bus_trans) analysis_export_golden;
uvm_analysis_export#(decoder_8b10b_trans) analysis_export_sample;

function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

extern virtual function void build_phase(uvm_phase phase);
extern virtual function void connect_phase(uvm_phase phase);
extern virtual function void set_not_in_table_error(bit error);
extern virtual function void set_disparity_error(bit error);
endclass

function void enc_8b10b_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    predictor = dec_predictor::type_id::create("predictor", this);
    predictor.not_in_table_error;
    predictor.disparity_error;

    evaluator = inorder_comparator#(decoder_8b10b_trans)::type_id::
        create("evaluator", this);
    evaluator.object_name = "decoder_8b10b_trans";

    analysis_export_golden = new("analysis_export_golden", this);
    analysis_export_sample = new("analysis_export_sample", this);
endfunction

function void enc_8b10b_scoreboard::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    analysis_export_golden.connect(predictor.analysis_export);
    analysis_export_sample.connect(evaluator.sample_export);

    evaluator.ap.connect(evaluator.golden_export);
endfunction

function void enc_8b10b_scoreboard::set_not_in_table_error(bit error);
    predictor.not_in_table_error = error;
endfunction

function void enc_8b10b_scoreboard::set_disparity_error(bit error);
    predictor.disparity_error = error;
endfunction
