import global_dec::*;
import erb2ila_dec::*;
class ILA_StateMachine;
    rx_jesd204b_layering_config m_cfg;
    // user should pass a handle of ila_info_extractor to this variable during 
    // build_phase
    ila_info_extractor m_ila_info_extractor;
    erb2ila_dec::ilastate_e currentState;
    erb2ila_dec::ilastate_e nextState;
    bit [2:0] kcounter;
    int ocounter;
    // 0 - increment ocounter at reception of next octet
    // 1 - reset ocounter at reception of next octet
    bit reset_octet_counter;
    int previous_af_position;
    // in software FSM, transition is called event, data/stimulus from
    // external associated with the event is event data
    // In this FSM, event data to cause transition is decoded symbol from
    // CGS FSM
    ila_trans eventData;

    function new();
        currentState = ILA_WAIT;
        kcounter = 3'd0;
        ocounter = 0;
        reset_octet_counter = 1'b0;
        previous_af_position = 0;
    endfunction

    extern function void update_currentstate();
    extern function void get_nextstate(ila_trans eventData);
    // do things based on current state and updated ila_trans
    extern function void state_func(ila_trans eventData);
    extern function void check_alignment(ila_trans t);
    extern function bit cross_coupling();
    extern function bit is_link_initialization(ila_trans frame);
    extern function bit is_ila_extraction_finished();
    extern function bit show_value_phadj();
    extern function bit is_adjustment_complete();
endclass


function void ILA_StateMachine::update_currentstate();
    currentState = nextState;
endfunction


function void ILA_StateMachine::get_nextstate(ila_trans eventData);
    case(currentState)
        ILA_WAIT: begin
            if (is_link_initialization(eventData))
                nextState = ILA_EVAL;
        end
        ILA_EVAL: begin
            if (is_ila_extraction_finished()) begin
                if (show_value_phadj())
                    nextState = ILA_ADJ;
                else
                    nextState = ILA_WAIT;
            end
        end
        ILA_ADJ: begin
            if (is_adjustment_complete())
                nextState = ILA_RPT;
        end
        ILA_RPT: nextState = ILA_WAIT;
        default: nextState = ILA_WAIT;
    endcase
endfunction


function void ILA_StateMachine::state_func(ila_trans eventData);
    case(currentState)
        ILA_WAIT: begin
        // resume error reporting
        // the indication bit may be temporarily put inside agent config class,
        // but ultimately I want to put it inside a RAL model for this agent
        end
        ILA_EVAL: begin
        // suspend error reporting
        end
        ILA_ADJ: begin
        end
        default: ocounter = 0;
    endcase
    eventData.ilastate = currentState;
endfunction


function void ILA_StateMachine::check_alignment(ila_trans t);
    if (t.is_control_word) begin
        if ((t.data == A || t.data == F) && t.valid) begin
            `uvm_info("IFS", "A/F detected", UVM_HIGH)
            // discrambling enabled
            if (m_cfg.scrambling_enable)
                t.is_control_word = 1'b0;

            if (((ocounter == previous_af_position) || cross_coupling()) &&
                t.valid) begin
                `uvm_info("IFS", "frame aligned, resetting ocounter", UVM_HIGH)
                reset_octet_counter = 1'b1;
            end
            if (t.valid || ocounter == (m_cfg.F-1))
                previous_af_position = ocounter;
        end
    end
endfunction


function bit ILA_StateMachine::cross_coupling();
// when frame misalignment is expected to happen transmitter disable IFS
// via control interface, for now it's a PLACEHOLDER
    return 0;
endfunction


function bit ILA_StateMachine::is_link_initialization(ila_trans frame);
// returns 1 when link initialization is detected
// returns 0 if no link initialization is detected
// link initialization condition is multiple K28.5 characters followed by
// the start of ILA
    logic [7:0] msb_of_frame[$];
    msb_of_frame = frame.data.find_last with {1};
    if (msb_of_frame.size) begin
        if (msb_of_frame[0] == global_dec::R)
            return 1;
    end

    return 0;
endfunction


function bit ILA_StateMachine::is_ila_extraction_finished();
// returns 1 if agent has received whole ILA sequence
// returns 0 if agent is receiving incoming ILA or no ILA has ever been
// received
    return m_ila_info_extractor.has_ila_finished();
endfunction


function bit ILA_StateMachine::show_value_phadj();
// return the value of PHADJ extracted from ILA
    return m_ila_info_extractor.PHADJ;
endfunction


function bit ILA_StateMachine::is_adjustment_complete();
    return 0;
endfunction
