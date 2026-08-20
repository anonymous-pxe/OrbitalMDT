// OrbitalMDT :: Centralized Mission State Manager
// Shared data model for inter-tab data flow and mission coordination.

global %ORBITAL_APP_STATE;

function state = init_app_state()
    // Initialize standard mission state structure.
    global %ORBITAL_APP_STATE;

    const = orbital_constants();

    state.departurePlanet = 3;  // Earth
    state.arrivalPlanet   = 4;  // Mars

    // Default dates: ~Earth to Mars 2026 window
    state.dep_year  = 2026;
    state.dep_month = 10;
    state.dep_day   = 1;
    state.arr_year  = 2027;
    state.arr_month = 6;
    state.arr_day   = 1;

    state.dep_jd = date_to_jd(state.dep_year, state.dep_month, state.dep_day);
    state.arr_jd = date_to_jd(state.arr_year, state.arr_month, state.arr_day);
    state.tof_days = state.arr_jd - state.dep_jd;

    // Transfer vectors & Lambert solution
    state.r1_vec    = zeros(3, 1);
    state.r2_vec    = zeros(3, 1);
    state.v1_trans  = zeros(3, 1);
    state.v2_trans  = zeros(3, 1);
    state.c3_dep    = 0;
    state.v_inf_dep = 0;
    state.v_inf_arr = 0;
    state.dv_total  = 0;
    state.converged = %F;

    // Rocket / Mass budget state
    state.m_dry  = 1000;   // kg
    state.m_pay  = 500;    // kg
    state.isp    = 320;    // s
    state.dv_req = 3.5;    // km/s

    %ORBITAL_APP_STATE = state;
endfunction


function state = get_app_state()
    // Retrieve current global mission state struct.
    global %ORBITAL_APP_STATE;
    if isempty(%ORBITAL_APP_STATE) then
        state = init_app_state();
    else
        state = %ORBITAL_APP_STATE;
    end
endfunction


function update_app_state(new_fields)
    // Update specific fields of the global mission state struct.
    global %ORBITAL_APP_STATE;
    if isempty(%ORBITAL_APP_STATE) then
        init_app_state();
    end

    fnames = fieldnames(new_fields);
    for k = 1:size(fnames, "*")
        fn = fnames(k);
        %ORBITAL_APP_STATE(fn) = new_fields(fn);
    end
endfunction
