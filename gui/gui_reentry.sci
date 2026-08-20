// OrbitalMDT :: Atmospheric Re-Entry Analysis Tab

function build_reentry_tab(fig)

    win_w = 1200; win_h = 800;
    try win_w = fig.axes_size(1); win_h = fig.axes_size(2); catch end

    y_base = win_h - 780;
    x_panel = 15;
    pw = 290;

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
    uicontrol(fig, 'style', 'edit', 'string', '-5.0', ..
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
        'string', 'Velocity vs Altitude|G-Loading vs Altitude|Heat Flux vs Altitude|Dynamic Pressure vs Alt|All Profiles', ..
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
          'Peak Dyn. Press: --        '; ..
          'Survivable:      --        '];

    for k = 1:6
        uicontrol(fig, 'style', 'text', 'string', rl(k,:), ..
            'position', [x_panel, y_base+295-k*23, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_re_result_' + string(k));
    end

    // Model Assumptions Banner
    uicontrol(fig, 'style', 'text', ..
        'string', 'Assumptions: 1D Ballistic Allen-Eggers, Sutton-Graves Convective Flux, Exponential Atmosphere', ..
        'position', [x_panel, y_base+130, pw, 22], 'fontsize', 7, ..
        'horizontalalignment', 'left', 'foreground', [0.5, 0.5, 0.5], ..
        'tag', 'content_re_assumptions');

    plot_w = max(400, win_w - 330);
    uicontrol(fig, 'style', 'text', ..
        'string', 'Re-entry analysis plots will appear here', ..
        'position', [310, floor(win_h / 2) - 20, plot_w, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_re_plot_placeholder');
endfunction


function cb_reentry_vehicle_preset()
    preset = get(findobj('tag', 'content_re_v_preset'), 'value');
    select preset
    case 2 // Apollo CM
        set(findobj('tag', 'content_re_beta'), 'string', '370');
        set(findobj('tag', 'content_re_rnose'), 'string', '4.69');
        set(findobj('tag', 'content_re_v_entry'), 'string', '11.0');
        set(findobj('tag', 'content_re_gamma'), 'string', '-6.5');
        set(findobj('tag', 'content_re_planet'), 'value', 1);
    case 3 // Soyuz
        set(findobj('tag', 'content_re_beta'), 'string', '210');
        set(findobj('tag', 'content_re_rnose'), 'string', '2.2');
        set(findobj('tag', 'content_re_v_entry'), 'string', '7.7');
        set(findobj('tag', 'content_re_gamma'), 'string', '-3.5');
        set(findobj('tag', 'content_re_planet'), 'value', 1);
    case 4 // Crew Dragon
        set(findobj('tag', 'content_re_beta'), 'string', '280');
        set(findobj('tag', 'content_re_rnose'), 'string', '3.7');
        set(findobj('tag', 'content_re_v_entry'), 'string', '7.8');
        set(findobj('tag', 'content_re_gamma'), 'string', '-4.0');
        set(findobj('tag', 'content_re_planet'), 'value', 1);
    case 5 // Mars Curiosity
        set(findobj('tag', 'content_re_beta'), 'string', '140');
        set(findobj('tag', 'content_re_rnose'), 'string', '2.25');
        set(findobj('tag', 'content_re_v_entry'), 'string', '5.8');
        set(findobj('tag', 'content_re_gamma'), 'string', '-15.5');
        set(findobj('tag', 'content_re_planet'), 'value', 2);
    case 6 // Stardust
        set(findobj('tag', 'content_re_beta'), 'string', '60');
        set(findobj('tag', 'content_re_rnose'), 'string', '0.23');
        set(findobj('tag', 'content_re_v_entry'), 'string', '12.9');
        set(findobj('tag', 'content_re_gamma'), 'string', '-8.2');
        set(findobj('tag', 'content_re_planet'), 'value', 1);
    end
endfunction


function cb_analyze_reentry()

    planet_id = get(findobj('tag', 'content_re_planet'), 'value');
    if planet_id == 1 then planet = "Earth"; else planet = "Mars"; end

    [v_entry, ok1, m1] = gui_get_positive_num('content_re_v_entry', 'Entry Velocity');
    if ~ok1 then gui_report_error(m1); return; end

    [gamma, ok2, m2] = gui_get_num('content_re_gamma', 'Flight Path Angle', -89.9, -0.1);
    if ~ok2 then gui_report_error(m2); return; end

    [h_entry, ok3, m3] = gui_get_positive_num('content_re_h_entry', 'Entry Altitude');
    if ~ok3 then gui_report_error(m3); return; end

    [beta_kgm2, ok4, m4] = gui_get_positive_num('content_re_beta', 'Ballistic Coefficient');
    if ~ok4 then gui_report_error(m4); return; end

    [R_nose, ok5, m5] = gui_get_positive_num('content_re_rnose', 'Nose Radius');
    if ~ok5 then gui_report_error(m5); return; end

    beta = beta_kgm2 * 1e6; // kg/km^2

    try
        result = ballistic_entry(v_entry, gamma, h_entry, beta, R_nose, planet);
    catch
        gui_report_error("Re-entry calculation error: " + lasterror());
        return;
    end

    set(findobj('tag', 'content_re_result_1'), 'string', ..
        msprintf('Peak Decel Alt: %.1f km', result.h_peak_decel));
    set(findobj('tag', 'content_re_result_2'), 'string', ..
        msprintf('Peak G-Loading: %.1f g', result.g_loading));
    set(findobj('tag', 'content_re_result_3'), 'string', ..
        msprintf('V at Peak:      %.3f km/s', result.v_peak_decel));
    set(findobj('tag', 'content_re_result_4'), 'string', ..
        msprintf('Peak Heat Flux: %.1f kW/m^2', result.q_peak));
    set(findobj('tag', 'content_re_result_5'), 'string', ..
        msprintf('Peak Dyn Press: %.1f kPa', result.peak_dyn_press));

    if result.g_loading < 10 then
        set(findobj('tag', 'content_re_result_6'), 'string', ..
            '[OK] Human Tolerable (<10g)');
    elseif result.g_loading < 20 then
        set(findobj('tag', 'content_re_result_6'), 'string', ..
            '[WARN] Extreme G-Load (10-20g)');
    else
        set(findobj('tag', 'content_re_result_6'), 'string', ..
            '[FAIL] Structural Hazard (>20g)');
    end

    ph = findobj('tag', 'content_re_plot_placeholder');
    if ph <> [] then
        for p_idx = 1:size(ph, "*")
            try delete(ph(p_idx)); catch try set(ph(p_idx), 'visible', 'off'); catch end end
        end
    end

    plot_type = get(findobj('tag', 'content_re_plottype'), 'value');

    ax = gui_create_plot_axes([0.32, 0.10, 0.64, 0.82]);
    fig = get_main_figure();

    select plot_type
    case 1 // Velocity vs Altitude
        plot(result.v_traj, result.h_traj, 'b-', 'LineWidth', 2);
        title(msprintf('%s Ballistic Re-Entry: Velocity vs Altitude', planet));
        xlabel('Velocity [km/s]'); ylabel('Altitude [km]'); xgrid();

    case 2 // G-Loading vs Altitude
        g0_ref = 9.80665e-3;
        if planet == "Mars" then g0_ref = 3.711e-3; end
        plot(result.a_traj / g0_ref, result.h_traj, 'r-', 'LineWidth', 2);
        title(msprintf('%s Ballistic Re-Entry: Deceleration Profile', planet));
        xlabel('Deceleration [g]'); ylabel('Altitude [km]'); xgrid();

    case 3 // Heat Flux vs Altitude
        plot(result.q_traj, result.h_traj, 'm-', 'LineWidth', 2);
        title(msprintf('%s Ballistic Re-Entry: Stagnation Heat Flux', planet));
        xlabel('Convective Heat Flux [kW/m^2]'); ylabel('Altitude [km]'); xgrid();

    case 4 // Dynamic Pressure vs Altitude
        plot(result.dyn_press_traj, result.h_traj, 'c-', 'LineWidth', 2);
        title(msprintf('%s Ballistic Re-Entry: Dynamic Pressure', planet));
        xlabel('Dynamic Pressure [kPa]'); ylabel('Altitude [km]'); xgrid();

    case 5 // All Profiles stacked
        ax.axes_bounds = [0.32, 0.06, 0.64, 0.23];
        plot(result.v_traj, result.h_traj, 'b-');
        title('Velocity [km/s]'); ylabel('Alt [km]'); xgrid();

        try; scf(fig); newaxes(fig); catch; newaxes(); end
        gca().axes_bounds = [0.32, 0.36, 0.64, 0.23];
        g0_ref = 9.80665e-3;
        if planet == "Mars" then g0_ref = 3.711e-3; end
        plot(result.a_traj / g0_ref, result.h_traj, 'r-');
        title('Deceleration [g]'); ylabel('Alt [km]'); xgrid();

        try; scf(fig); newaxes(fig); catch; newaxes(); end
        gca().axes_bounds = [0.32, 0.66, 0.64, 0.23];
        plot(result.q_traj, result.h_traj, 'm-');
        title('Heat Flux [kW/m^2]'); xlabel('Profile values'); ylabel('Alt [km]'); xgrid();
    end

    update_status(msprintf('Re-entry analysis complete: Peak Decel=%.1fg at %.1fkm, Peak Heat=%.1f kW/m^2', ..
        result.g_loading, result.h_peak_decel, result.q_peak));
endfunction
