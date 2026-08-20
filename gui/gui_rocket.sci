// OrbitalMDT :: Rocket Equation & Mass Budget Tab

function build_rocket_tab(fig)

    win_w = 1200; win_h = 800;
    try win_w = fig.axes_size(1); win_h = fig.axes_size(2); catch end

    y_base = win_h - 780;
    x_panel = 15;
    pw = 290;

    uicontrol(fig, 'style', 'text', 'string', '[*] ROCKET EQUATION & MASS BUDGET', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.8, 0.2, 0.2], 'tag', 'content_rk_title');

    uicontrol(fig, 'style', 'text', 'string', 'Mission Preset:', ..
        'position', [x_panel, y_base+630, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl0');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Custom|LEO|GEO|Moon Landing|Mars Landing|Venus Orbit|Jupiter Orbit', ..
        'position', [x_panel+120, y_base+628, 155, 25], 'fontsize', 10, ..
        'tag', 'content_rk_preset', 'callback', 'cb_rocket_preset()');

    uicontrol(fig, 'style', 'text', 'string', 'Total Delta-V (km/s):', ..
        'position', [x_panel, y_base+598, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl1');
    uicontrol(fig, 'style', 'edit', 'string', '9.4', ..
        'position', [x_panel+140, y_base+596, 135, 25], 'fontsize', 10, ..
        'tag', 'content_rk_dv');

    uicontrol(fig, 'style', 'text', 'string', 'Specific Impulse (s):', ..
        'position', [x_panel, y_base+566, 160, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl2');
    uicontrol(fig, 'style', 'edit', 'string', '350', ..
        'position', [x_panel+160, y_base+564, 115, 25], 'fontsize', 10, ..
        'tag', 'content_rk_isp');

    uicontrol(fig, 'style', 'text', 'string', 'Engine Preset:', ..
        'position', [x_panel, y_base+534, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl2b');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Custom|Merlin 1D (282s)|Raptor (350s)|RS-25 (452s)|RL-10 (465s)|Ion (3000s)|NERVA (900s)', ..
        'position', [x_panel+120, y_base+532, 155, 25], 'fontsize', 10, ..
        'tag', 'content_rk_engine', 'callback', 'cb_engine_preset()');

    uicontrol(fig, 'style', 'text', 'string', 'Payload Mass (kg):', ..
        'position', [x_panel, y_base+502, 160, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl3');
    uicontrol(fig, 'style', 'edit', 'string', '5000', ..
        'position', [x_panel+160, y_base+500, 115, 25], 'fontsize', 10, ..
        'tag', 'content_rk_payload');

    uicontrol(fig, 'style', 'pushbutton', 'string', 'Load from Mission State', ..
        'position', [x_panel, y_base+466, pw, 26], ..
        'fontsize', 10, 'callback', 'cb_load_mission_state_rocket()', ..
        'tag', 'content_rk_load_state');

    uicontrol(fig, 'style', 'pushbutton', 'string', 'CALCULATE MASS BUDGET', ..
        'position', [x_panel, y_base+432, pw, 28], ..
        'fontsize', 11, 'fontweight', 'bold', ..
        'background', [0.8, 0.2, 0.2], 'foreground', [1, 1, 1], ..
        'callback', 'cb_calculate_rocket()', 'tag', 'content_rk_calculate');

    uicontrol(fig, 'style', 'text', 'string', '[*] MASS BUDGET RESULTS', ..
        'position', [x_panel, y_base+400, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.7, 0.1, 0.1], 'tag', 'content_rk_res_title');

    rl = ['Exhaust Velocity:  --      '; ..
          'Mass Ratio:        --      '; ..
          'Payload Mass:      --      '; ..
          'Propellant Mass:   --      '; ..
          'Total Init Mass:   --      '; ..
          'Propellant Frac:   --      '; ..
          'Wet/Dry Ratio:     --      '];

    for k = 1:7
        uicontrol(fig, 'style', 'text', 'string', rl(k,:), ..
            'position', [x_panel, y_base+400-k*20, pw, 18], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_rk_result_' + string(k));
    end

    uicontrol(fig, 'style', 'text', 'string', '[*] Delta-V BUDGET BREAKDOWN', ..
        'position', [x_panel, y_base+240, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.7, 0.1, 0.1], 'tag', 'content_rk_budget_title');

    for k = 1:5
        uicontrol(fig, 'style', 'text', 'string', '', ..
            'position', [x_panel, y_base+240-k*20, pw, 18], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_rk_budget_' + string(k));
    end

    // Model Assumptions Banner
    uicontrol(fig, 'style', 'text', ..
        'string', 'Assumptions: Ideal Tsiolkovsky, Impulsive Burn, Constant Isp, g0=9.80665 m/s^2', ..
        'position', [x_panel, y_base+115, pw, 18], 'fontsize', 8, ..
        'horizontalalignment', 'left', 'foreground', [0.5, 0.5, 0.5], ..
        'tag', 'content_rk_assumptions');

    plot_w = max(400, win_w - 330);
    uicontrol(fig, 'style', 'text', ..
        'string', 'Mass budget visualization will appear here', ..
        'position', [310, floor(win_h / 2) - 20, plot_w, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_rk_plot_placeholder');
endfunction


function cb_rocket_preset()
    preset = get(findobj('tag', 'content_rk_preset'), 'value');
    mission_keys = ['Custom', 'LEO', 'GEO', 'Moon', 'Mars', 'Venus', 'Jupiter'];
    dvs = [0, 9.4, 13.34, 15.22, 14.7, 13.8, 17.7];

    if preset > 1 then
        set(findobj('tag', 'content_rk_dv'), 'string', string(dvs(preset)));

        result = mission_dv_budget(mission_keys(preset));
        n_seg = min(5, size(result.segments, "*"));
        for k = 1:n_seg
            set(findobj('tag', 'content_rk_budget_' + string(k)), 'string', ..
                msprintf('%s: %.2f km/s', result.segments(k), result.dvs(k)));
        end
        for k = (n_seg+1):5
            set(findobj('tag', 'content_rk_budget_' + string(k)), 'string', '');
        end
    end
endfunction


function cb_engine_preset()
    preset = get(findobj('tag', 'content_rk_engine'), 'value');
    isps = [0, 282, 350, 452, 465, 3000, 900];
    if preset > 1 then
        set(findobj('tag', 'content_rk_isp'), 'string', string(isps(preset)));
    end
endfunction


function cb_calculate_rocket()

    [dv, ok1, m1] = gui_get_positive_num('content_rk_dv', 'Total Delta-V');
    if ~ok1 then gui_report_error(m1); return; end

    [Isp, ok2, m2] = gui_get_positive_num('content_rk_isp', 'Specific Impulse (Isp)');
    if ~ok2 then gui_report_error(m2); return; end

    [m_pay, ok3, m3] = gui_get_positive_num('content_rk_payload', 'Payload Mass');
    if ~ok3 then gui_report_error(m3); return; end

    try
        result = rocket_equation(dv, Isp, m_pay);
    catch
        gui_report_error("Failed to compute mass budget: " + lasterror());
        return;
    end

    set(findobj('tag', 'content_rk_result_1'), 'string', ..
        msprintf('Exhaust Vel:   %.3f km/s', result.v_exhaust));
    set(findobj('tag', 'content_rk_result_2'), 'string', ..
        msprintf('Mass Ratio:    %.3f', result.mass_ratio));
    set(findobj('tag', 'content_rk_result_3'), 'string', ..
        msprintf('Payload:       %.0f kg', result.m_payload));
    set(findobj('tag', 'content_rk_result_4'), 'string', ..
        msprintf('Propellant:    %.0f kg', result.m_propellant));
    set(findobj('tag', 'content_rk_result_5'), 'string', ..
        msprintf('Total Init:    %.0f kg', result.m_initial));
    set(findobj('tag', 'content_rk_result_6'), 'string', ..
        msprintf('Prop Fraction: %.1f%%', result.prop_fraction*100));
    set(findobj('tag', 'content_rk_result_7'), 'string', ..
        msprintf('Wet/Dry:       %.2f', result.mass_ratio));

    ph = findobj('tag', 'content_rk_plot_placeholder');
    if ph <> [] then
        for p_idx = 1:size(ph, "*")
            try delete(ph(p_idx)); catch try set(ph(p_idx), 'visible', 'off'); catch end end
        end
    end

    a = gui_create_plot_axes([0.32, 0.10, 0.64, 0.82]);

    bar([1, 2], [result.m_payload, result.m_propellant]);
    gca().x_ticks = tlist(['ticks', 'locations', 'labels'], [1, 2], ['Payload Dry Mass', 'Propellant Mass']);
    ylabel('Mass [kg]');
    title(msprintf('Mass Budget: dV=%.2f km/s, Isp=%.0fs (Total Mass = %.0f kg)', dv, Isp, result.m_initial));
    max_m = max(result.m_payload, result.m_propellant);
    xstring(0.85, max(result.m_payload + 0.03*max_m, 0.05*max_m), msprintf('%.0f kg', result.m_payload));
    xstring(1.85, result.m_propellant + 0.03*max_m, msprintf('%.0f kg', result.m_propellant));

    update_status(msprintf('Rocket: %.0f kg payload requires %.0f kg propellant (Total = %.0f kg, Prop. Frac = %.1f%%)', ..
        result.m_payload, result.m_propellant, result.m_initial, result.prop_fraction*100));
endfunction


function cb_load_mission_state_rocket()
    st = get_app_state();
    if st.dv_req > 0 then
        set(findobj('tag', 'content_rk_dv'), 'string', msprintf('%.3f', st.dv_req));
        update_status(msprintf('Loaded Delta-V (%.3f km/s) from central mission state!', st.dv_req));
    else
        gui_report_error('No active mission Delta-V found in state. Run Mission Planner first.');
    end
endfunction
