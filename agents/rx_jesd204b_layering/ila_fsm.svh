import global_dec::*;
import erb2ila_dec::*;
class ILA_StateMachine;
// this class would be used in both erb2ila_monitor and ila2erb_seq,
// ila2erb_seq would use full features of this class, erb2ila_monitor would
// only use get_nextstate() method and other variables since monitor only
// observes.
    rx_jesd204b_layering_config m_cfg;
    // user should pass a handle of ila_info_extractor to this variable during
    // build_phase
    ila_info_extractor m_ila_info_extractor;
    erb2ila_dec::ilastate_e currentState;
    erb2ila_dec::ilastate_e nextState;
    // in software FSM, transition is called event, data/stimulus from
    // external associated with the event is event data
    // In this FSM, event data to cause transition is decoded symbol from
    // CGS FSM


    function new();
        currentState = ILA_WAIT;
    endfunction

    extern function void update_currentstate();
    extern function void get_nextstate(erb_trans eventData);
    // do things based on current state and updated ila_trans
    extern function void state_func(ila_trans eventData);
    extern function bit is_link_initialising(erb_trans frame);
    extern function bit is_ila_extraction_finished();
    extern function bit get_phadj();
    extern function bit[3:0] get_adjcnt();
    extern function bit get_adjdir();
    extern function bit is_adjustment_complete();
endclass


function void ILA_StateMachine::update_currentstate();
    currentState = nextState;
endfunction


function void ILA_StateMachine::get_nextstate(erb_trans eventData);
    case(currentState)
        ILA_WAIT: begin
            if (is_link_initialising(eventData))
                nextState = ILA_EVAL;
            else
                nextState = ILA_WAIT;
        end
        ILA_EVAL: begin
            if (is_ila_extraction_finished()) begin
                if (get_phadj())
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
            eventData.err_report = 1'b0;
        end
        ILA_ADJ: begin
        // this should be moved to RAL later
            m_cfg.PHADJ = this.get_phadj();
            m_cfg.ADJCNT = this.get_adjcnt();
            m_cfg.ADJDIR = this.get_adjdir();
            m_cfg.lmfc_adj_start = 1'b1;
            eventData.err_report = 1'b0;
        end
        ILA_RPT: begin
            eventData.err_report = 1'b1;
        end
        default: begin
        // resume error reporting
        end
    endcase
    eventData.ilastate = currentState;
endfunction


function bit ILA_StateMachine::is_link_initialising(erb_trans frame);
// returns 1 when link initialization is detected
// returns 0 if no link initialization is detected
// link initialization condition is multiple K28.5 characters followed by
// the start of ILA
    byte unsigned msb_of_frame[$];
    msb_of_frame = frame.data.find_last with (1);
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


function bit ILA_StateMachine::get_phadj();
// returns the value of PHADJ extracted from ILA
    return m_ila_info_extractor.PHADJ;
endfunction


function bit[3:0] ILA_StateMachine::get_adjcnt();
// returns the value of ADJCNT extracted from ILA
    return m_ila_info_extractor.ADJCNT;
endfunction


function bit ILA_StateMachine::get_adjdir();
// returns the value of ADJDIR extracted from ILA
    return m_ila_info_extractor.ADJDIR;
endfunction


function bit ILA_StateMachine::is_adjustment_complete();
// returns 1 if LMFC phase adjustment durin 3rd state in TX ILA statemachine
// finished.
// returns 0 if the adjustment state above is not finished yet or statemachine
// is not at 3rd state
    return ~m_cfg.lmfc_adj_start;
endfunction
