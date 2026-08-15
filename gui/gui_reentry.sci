// OrbitalMDT :: Atmospheric Re-Entry Analysis Tab

function build_reentry_tab(fig)

    y_base = 25;
    x_panel = 15;
    pw = 280;

    uicontrol(fig, 'style', 'text', 'string', '[*] ATMOSPHERIC RE-ENTRY ANALYSIS', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.2, 0.7, 0.7], 'tag', 'content_re_title');

    uicontrol(fig, 'style', 'text', 'string', 'Planet:', ..
        'position', [x_panel, y_base+632, 80, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_planet_lbl');
    uicontrol(fig, 'style', 'popupmenu', 'string', 'Earth|Mars', ..
        'position', [x_panel+80, y_base+630, 195, 25], 'fontsize', 10, ..
        'tag', 'content_re_planet');

    uicontrol(fig, 'style', 'text', 'string', '-- Entry Conditions --', ..
        'position', [x_panel, y_base+600, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_re_lbl_sec');

    uicontrol(fig, 'style', 'text', 'string', 'Entry Velocity (km/s):', ..
        'position', [x_panel, y_base+575, 160, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_lbl1');
    uicontrol(fig, 'style', 'edit', 'string', '7.8', ..
        'position', [x_panel+165, y_base+573, 110, 25], 'fontsize', 10, ..
        'tag', 'content_re_v_entry');

    uicontrol(fig, 'style', 'text', 'string', 'Entry Angle (deg, neg):', ..
        'position', [x_panel, y_base+545, 160, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_lbl2');
    uicontrol(fig, 'style', 'edit', 'string', '-5', ..
        'position', [x_panel+165, y_base+543, 110, 25], 'fontsize', 10, ..
        'tag', 'content_re_gamma');

    uicontrol(fig, 'style', 'text', 'string', 'Entry Altitude (km):', ..
        'position', [x_panel, y_base+515, 160, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_lbl3');
    uicontrol(fig, 'style', 'edit', 'string', '120', ..
        'position', [x_panel+165, y_base+513, 110, 25], 'fontsize', 10, ..
        'tag', 'content_re_h_entry');

    uicontrol(fig, 'style', 'text', 'string', '-- Vehicle Parameters --', ..
        'position', [x_panel, y_base+483, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_re_lbl_sec2');

    uicontrol(fig, 'style', 'text', 'string', 'Ballistic Coeff (kg/m^2):', ..
        'position', [x_panel, y_base+458, 170, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_lbl4');
    uicontrol(fig, 'style', 'edit', 'string', '100', ..
        'position', [x_panel+170, y_base+456, 105, 25], 'fontsize', 10, ..
        'tag', 'content_re_beta');

    uicontrol(fig, 'style', 'text', 'string', 'Nose Radius (m):', ..
        'position', [x_panel, y_base+428, 170, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_lbl5');
    uicontrol(fig, 'style', 'edit', 'string', '1.0', ..
        'position', [x_panel+170, y_base+426, 105, 25], 'fontsize', 10, ..
        'tag', 'content_re_rnose');

    uicontrol(fig, 'style', 'text', 'string', 'Vehicle Preset:', ..
        'position', [x_panel, y_base+398, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_lbl6');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Custom|Apollo CM|Soyuz|Crew Dragon|Mars Curiosity|Stardust', ..
        'position', [x_panel+120, y_base+396, 155, 25], 'fontsize', 10, ..
        'tag', 'content_re_v_preset', 'callback', 'cb_reentry_vehicle_preset()');

    uicontrol(fig, 'style', 'text', 'string', 'Plot:', ..
        'position', [x_panel, y_base+368, 50, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_re_lbl7');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Velocity vs Altitude|G-Loading vs Altitude|Heat Flux vs Altitude|All Plots', ..
        'position', [x_panel+50, y_base+366, 225, 25], 'fontsize', 10, ..
        'tag', 'content_re_plottype');

    uicontrol(fig, 'style', 'pushbutton', 'string', 'ANALYZE RE-ENTRY', ..
        'position', [x_panel, y_base+325, pw, 35], ..
        'fontsize', 12, 'fontweight', 'bold', ..
        'background', [0.2, 0.7, 0.7], 'foreground', [1, 1, 1], ..
        'callback', 'cb_analyze_reentry()', 'tag', 'content_re_analyze');

    uicontrol(fig, 'style', 'text', 'string', '[*] RE-ENTRY RESULTS', ..
        'position', [x_panel, y_base+295, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.1, 0.6, 0.6], 'tag', 'content_re_res_title');

    rl = ['Peak Decel Alt:  --        '; ..
          'Peak G-Loading:  --        '; ..
          'V at Peak Decel: --        '; ..
          'Peak Heat Flux:  --        '; ..
          'Total Heat Load: --        '; ..
          'Survivable:      --        '];

    for k = 1:6
        uicontrol(fig, 'style', 'text', 'string', rl(k,:), ..
            'position', [x_panel, y_base+295-k*23, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_re_result_' + string(k));
    end

    uicontrol(fig, 'style', 'text', ..
        'string', 'Re-entry analysis plots will appear here', ..
        'position', [310, y_base+300, 870, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_re_plot_placeholder');
endfunction


function cb_reentry_vehicle_preset()
    preset = get(findobj('tag', 'content_re_v_preset'), 'value');
    select preset
    case 2
        set(findobj('tag', 'content_re_beta'), 'string', '370');
        set(findobj('tag', 'content_re_rnose'), 'string', '4.69');
        set(findobj('tag', 'content_re_v_entry'), 'string', '11.0');
        set(findobj('tag', 'content_re_gamma'), 'string', '-6.5');
    case 3
        set(findobj('tag', 'content_re_beta'), 'string', '210');
        set(findobj('tag', 'content_re_rnose'), 'string', '2.2');
        set(findobj('tag', 'content_re_v_entry'), 'string', '7.7');
        set(findobj('tag', 'content_re_gamma'), 'string', '-3.5');
    case 4
        set(findobj('tag', 'content_re_beta'), 'string', '280');
        set(findobj('tag', 'content_re_rnose'), 'string', '3.7');
        set(findobj('tag', 'content_re_v_entry'), 'string', '7.8');
        set(findobj('tag', 'content_re_gamma'), 'string', '-4.0');
    case 5
        set(findobj('tag', 'content_re_beta'), 'string', '140');
        set(findobj('tag', 'content_re_rnose'), 'string', '2.25');
        set(findobj('tag', 'content_re_v_entry'), 'string', '5.8');
        set(findobj('tag', 'content_re_gamma'), 'string', '-15.5');
        set(findobj('tag', 'content_re_planet'), 'value', 2);
    case 6
        set(findobj('tag', 'content_re_beta'), 'string', '60');
        set(findobj('tag', 'content_re_rnose'), 'string', '0.23');
        set(findobj('tag', 'content_re_v_entry'), 'string', '12.9');
        set(findobj('tag', 'content_re_gamma'), 'string', '-8.2');
    end
endfunction


function cb_analyze_reentry()

    planet_id = get(findobj('tag', 'content_re_planet'), 'value');
    if planet_id == 1 then planet = "Earth"; else planet = "Mars"; end

    v_entry   = strtod(get(findobj('tag', 'content_re_v_entry'), 'string'));
    gamma     = strtod(get(findobj('tag', 'content_re_gamma'), 'string'));
    h_entry   = strtod(get(findobj('tag', 'content_re_h_entry'), 'string'));
    beta_kgm2 = strtod(get(findobj('tag', 'content_re_beta'), 'string'));
    R_nose    = strtod(get(findobj('tag', 'content_re_rnose'), 'string'));

    beta = beta_kgm2 * 1e6;

    result = ballistic_entry(v_entry, gamma, h_entry, beta, R_nose, planet);

    set(findobj('tag', 'content_re_result_1'), 'string', ..
        msprintf('Peak Decel Alt: %.1f km', result.h_peak_decel));
    set(findobj('tag', 'content_re_result_2'), 'string', ..
        msprintf('Peak G-Loading: %.1f g', result.g_loading));
    set(findobj('tag', 'content_re_result_3'), 'string', ..
        msprintf('V at Peak:      %.3f km/s', result.v_peak_decel));
    set(findobj('tag', 'content_re_result_4'), 'string', ..
        msprintf('Peak Heat Flux: %.1f kW/m^2', result.q_peak));
    set(findobj('tag', 'content_re_result_5'), 'string', ..
        msprintf('Heat Load:      %.0f kJ/m^2', result.Q_total));

    if result.g_loading < 10 then
        set(findobj('tag', 'content_re_result_6'), 'string', ..
            '[OK] Survivable: Yes (< 10g)');
    elseif result.g_loading < 20 then
        set(findobj('tag', 'content_re_result_6'), 'string', ..
            '[WARN] Survivable: Marginal (10-20g)');
    else
        set(findobj('tag', 'content_re_result_6'), 'string', ..
            '[FAIL] Survivable: Extreme (> 20g)');
    end

    ph = findobj('tag', 'content_re_plot_placeholder');
    if ph <> [] then set(ph, 'visible', 'off'); end

    plot_type = get(findobj('tag', 'content_re_plottype'), 'value');

    select plot_type
    case 1
        newaxes();
        gca().axes_bounds = [0.28, 0.05, 0.70, 0.90];
        plot(result.v_traj, result.h_traj, 'b-', 'LineWidth', 2);
        xlabel('Velocity [km/s]'); ylabel('Altitude [km]');
        title('Entry Velocity Profile'); xgrid();

    case 2
        newaxes();
        gca().axes_bounds = [0.28, 0.05, 0.70, 0.90];
        g_load = result.a_traj / 9.80665e-3;
        plot(g_load, result.h_traj, 'r-', 'LineWidth', 2);
        xlabel('Deceleration [g]'); ylabel('Altitude [km]');
        title('G-Loading Profile'); xgrid();

    case 3
        newaxes();
        gca().axes_bounds = [0.28, 0.05, 0.70, 0.90];
        plot(result.q_traj, result.h_traj, 'm-', 'LineWidth', 2);
        xlabel('Heat Flux [kW/m^2]'); ylabel('Altitude [km]');
        title('Stagnation Point Heat Flux'); xgrid();

    case 4
        newaxes();
        gca().axes_bounds = [0.28, 0.05, 0.22, 0.90];
        plot(result.v_traj, result.h_traj, 'b-', 'LineWidth', 2);
        xlabel('V [km/s]'); ylabel('Alt [km]'); title('Velocity'); xgrid();

        newaxes();
        gca().axes_bounds = [0.52, 0.05, 0.22, 0.90];
        g_load = result.a_traj / 9.80665e-3;
        plot(g_load, result.h_traj, 'r-', 'LineWidth', 2);
        xlabel('G-load [g]'); ylabel('Alt [km]'); title('G-Loading'); xgrid();

        newaxes();
        gca().axes_bounds = [0.76, 0.05, 0.22, 0.90];
        plot(result.q_traj, result.h_traj, 'm-', 'LineWidth', 2);
        xlabel('q [kW/m^2]'); ylabel('Alt [km]'); title('Heat Flux'); xgrid();
    end

    update_status(msprintf('Re-entry: Peak %.1f g at %.0f km, Heat %.0f kW/m^2', ..
        result.g_loading, result.h_peak_decel, result.q_peak));
endfunction
