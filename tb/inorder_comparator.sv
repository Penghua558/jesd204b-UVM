`uvm_analysis_imp_decl(_golden)
`uvm_analysis_imp_decl(_sample)
class inorder_comparator#(type T = uvm_sequence_item) extends uvm_component;

`uvm_component_param_utils(inorder_comparator#(T))

uvm_analysis_imp_golden#(T, inorder_comparator) golden_export;
uvm_analysis_imp_sample#(T, inorder_comparator) sample_export;

string object_name;
int m_matches;
int m_mismatches;
protected T m_golden[$];
protected T m_sample[$];

function new(string name, uvm_component parent);
    super.new(name, parent);
    m_matches = 0;
    m_mismatches = 0;
endfunction

extern virtual function void m_proc_data();
extern virtual function void write_golden(T txn);
extern virtual function void write_sample(T txn);
extern virtual function void report_phase(uvm_phase phase);
endclass

function void inorder_comparator::write_golden(T txn);
    m_golden.push_back(txn);
    if (m_sample.size())
        m_proc_data();
endfunction

function void inorder_comparator::write_sample(T txn);
    m_sample.push_back(txn);
    if (m_golden.size())
        m_proc_data();
endfunction

function void inorder_comparator::m_proc_data();
    T golden_txn = m_golden.pop_front();
    T sample_txn = m_sample.pop_front();

    if(!golden_txn.compare(sample_txn)) begin
        `uvm_error("Comparator Mismatch", 
            $sformatf("transaction mismtach, golden transaction: %s\n\
            sample transaction: %s", golden_txn.sprint(), sample_txn.sprint()))
        m_mismatches++;
    end else begin
        m_matches++;
    end
endfunction

function void inorder_comparator::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("Inorder Comparator", 
        $sformatf("%s matches: %0d", object_name, m_matches), UVM_LOW)
    `uvm_info("Inorder Comparator", 
        $sformatf("%s mismatches: %0d", object_name, m_mismatches), UVM_LOW)
    if (m_golden.size()) begin
        `uvm_info("Inorder Comparator", 
            $sformatf("%s golden transaction ummatches: %0d", 
            object_name, m_golden.size()), UVM_LOW)
    end
    if (m_sample.size()) begin
        `uvm_info("Inorder Comparator", 
            $sformatf("%s sample transaction ummatches: %0d", 
            object_name, m_sample.size()), UVM_LOW)
    end
endfunction
