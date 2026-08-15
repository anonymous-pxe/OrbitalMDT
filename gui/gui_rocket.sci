// OrbitalMDT :: Rocket Equation & Mass Budget Tab

function build_rocket_tab(fig)

    y_base = 25;
    x_panel = 15;
    pw = 280;

    uicontrol(fig, 'style', 'text', 'string', '[*] ROCKET EQUATION & MASS BUDGET', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.8, 0.2, 0.2], 'tag', 'content_rk_title');

    uicontrol(fig, 'style', 'text', 'string', 'Mission Preset:', ..
        'position', [x_panel, y_base+632, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl0');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Custom|LEO|GEO|Moon Landing|Mars Landing|Venus Orbit|Jupiter Orbit', ..
        'position', [x_panel+120, y_base+630, 155, 25], 'fontsize', 10, ..
        'tag', 'content_rk_preset', 'callback', 'cb_rocket_preset()');

    uicontrol(fig, 'style', 'text', 'string', 'Total Delta-V (km/s):', ..
        'position', [x_panel, y_base+600, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl1');
    uicontrol(fig, 'style', 'edit', 'string', '9.4', ..
        'position', [x_panel+140, y_base+598, 135, 25], 'fontsize', 10, ..
        'tag', 'content_rk_dv');

    uicontrol(fig, 'style', 'text', 'string', 'Specific Impulse (s):', ..
        'position', [x_panel, y_base+570, 160, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl2');
    uicontrol(fig, 'style', 'edit', 'string', '350', ..
        'position', [x_panel+160, y_base+568, 115, 25], 'fontsize', 10, ..
        'tag', 'content_rk_isp');

    uicontrol(fig, 'style', 'text', 'string', 'Engine Preset:', ..
        'position', [x_panel, y_base+540, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl2b');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Custom|Merlin 1D (282s)|Raptor (350s)|RS-25 (452s)|RL-10 (465s)|Ion (3000s)|NERVA (900s)', ..
        'position', [x_panel+120, y_base+538, 155, 25], 'fontsize', 10, ..
        'tag', 'content_rk_engine', 'callback', 'cb_engine_preset()');

    uicontrol(fig, 'style', 'text', 'string', 'Payload Mass (kg):', ..
        'position', [x_panel, y_base+508, 160, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_rk_lbl3');
    uicontrol(fig, 'style', 'edit', 'string', '5000', ..
        'position', [x_panel+160, y_base+506, 115, 25], 'fontsize', 10, ..
        'tag', 'content_rk_payload');

    uicontrol(fig, 'style', 'pushbutton', 'string', 'CALCULATE MASS BUDGET', ..
        'position', [x_panel, y_base+465, pw, 35], ..
        'fontsize', 12, 'fontweight', 'bold', ..
        'background', [0.8, 0.2, 0.2], 'foreground', [1, 1, 1], ..
        'callback', 'cb_calculate_rocket()', 'tag', 'content_rk_calculate');

    uicontrol(fig, 'style', 'text', 'string', '[*] MASS BUDGET RESULTS', ..
        'position', [x_panel, y_base+435, pw, 22], ..
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
            'position', [x_panel, y_base+435-k*23, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_rk_result_' + string(k));
    end

    uicontrol(fig, 'style', 'text', 'string', '[*] Delta-V BUDGET BREAKDOWN', ..
        'position', [x_panel, y_base+260, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.7, 0.1, 0.1], 'tag', 'content_rk_budget_title');

    for k = 1:5
        uicontrol(fig, 'style', 'text', 'string', '', ..
            'position', [x_panel, y_base+260-k*22, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_rk_budget_' + string(k));
    end

    uicontrol(fig, 'style', 'text', ..
        'string', 'Mass budget visualization will appear here', ..
        'position', [310, y_base+300, 870, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_rk_plot_placeholder');
endfunction


function cb_rocket_preset()
    preset = get(findobj('tag', 'content_rk_preset'), 'value');
    // keys must match mission_dv_budget() select cases
    mission_keys = ['Custom', 'LEO', 'GEO', 'Moon', 'Mars', 'Venus', 'Jupiter'];
    dvs = [0, 9.4, 13.34, 15.22, 14.7, 13.8, 17.7];

    if preset > 1 then
        set(findobj('tag', 'content_rk_dv'), 'string', string(dvs(preset)));

        result = mission_dv_budget(mission_keys(preset));
        n_seg = min(5, length(result.segments));
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

    dv    = strtod(get(findobj('tag', 'content_rk_dv'), 'string'));
    Isp   = strtod(get(findobj('tag', 'content_rk_isp'), 'string'));
    m_pay = strtod(get(findobj('tag', 'content_rk_payload'), 'string'));

    result = rocket_equation(dv, Isp, m_pay);

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
    if ph <> [] then set(ph, 'visible', 'off'); end

    newaxes();
    a = gca();
    a.axes_bounds = [0.28, 0.05, 0.70, 0.90];

    bar([1, 2], [result.m_payload, result.m_propellant]);
    gca().x_ticks = tlist(['ticks', 'locations', 'labels'], [1, 2], ['Payload', 'Propellant']);
    ylabel('Mass [kg]');
    title(msprintf('Mass Budget: dV=%.1f km/s, Isp=%ds', dv, Isp));
    xstring(0.8, result.m_payload * 1.05, msprintf('%.0f kg', result.m_payload));
    xstring(1.8, result.m_propellant * 1.05, msprintf('%.0f kg', result.m_propellant));

    update_status(msprintf('Rocket: %.0f kg payload needs %.0f kg propellant (%.1f%%)', ..
        result.m_payload, result.m_propellant, result.prop_fraction*100));
endfunction
