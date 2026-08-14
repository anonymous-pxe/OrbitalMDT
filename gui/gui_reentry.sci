// ============================================================================
// OrbitalMDT — Atmospheric Re-Entry Analysis Tab
// ============================================================================

function build_reentry_tab(fig)
    // Build the Re-Entry Analysis tab
    
    y_base = 25;
    x_panel = 15;
    panel_w = 280;
    
    // ---- Title ----
    uicontrol(fig, 'style', 'text', 'string', '■ ATMOSPHERIC RE-ENTRY ANALYSIS', ...
        'position', [x_panel, y_base+660, panel_w, 22], ...
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ...
        'foreground', [0.2, 0.7, 0.7], 'tag', 'content_re_title');
    
    // ---- Planet ----
    uicontrol(fig, 'style', 'text', 'string', 'Planet:', ...
        'position', [x_panel, y_base+632, 80, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl0');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Earth|Mars', ...
        'position', [x_panel+80, y_base+630, 195, 25], 'fontsize', 10, ...
        'tag', 'content_re_planet');
    
    // ---- Entry Conditions ----
    uicontrol(fig, 'style', 'text', 'string', '— Entry Conditions —', ...
        'position', [x_panel, y_base+600, panel_w, 20], 'fontsize', 10, ...
        'fontweight', 'bold', 'horizontalalignment', 'center', ...
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_re_lbl_sec');
    
    // Entry velocity
    uicontrol(fig, 'style', 'text', 'string', 'Entry Velocity (km/s):', ...
        'position', [x_panel, y_base+575, 160, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl1');
    uicontrol(fig, 'style', 'edit', 'string', '7.8', ...
        'position', [x_panel+165, y_base+573, 110, 25], 'fontsize', 10, ...
        'tag', 'content_re_v_entry');
    
    // Entry angle
    uicontrol(fig, 'style', 'text', 'string', 'Entry Angle (°, neg):', ...
        'position', [x_panel, y_base+545, 160, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl2');
    uicontrol(fig, 'style', 'edit', 'string', '-5', ...
        'position', [x_panel+165, y_base+543, 110, 25], 'fontsize', 10, ...
        'tag', 'content_re_gamma');
    
    // Entry altitude
    uicontrol(fig, 'style', 'text', 'string', 'Entry Altitude (km):', ...
        'position', [x_panel, y_base+515, 160, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl3');
    uicontrol(fig, 'style', 'edit', 'string', '120', ...
        'position', [x_panel+165, y_base+513, 110, 25], 'fontsize', 10, ...
        'tag', 'content_re_h_entry');
    
    // ---- Vehicle Parameters ----
    uicontrol(fig, 'style', 'text', 'string', '— Vehicle Parameters —', ...
        'position', [x_panel, y_base+483, panel_w, 20], 'fontsize', 10, ...
        'fontweight', 'bold', 'horizontalalignment', 'center', ...
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_re_lbl_sec2');
    
    // Ballistic coefficient
    uicontrol(fig, 'style', 'text', 'string', 'Ballistic Coeff (kg/m²):', ...
        'position', [x_panel, y_base+458, 170, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl4');
    uicontrol(fig, 'style', 'edit', 'string', '100', ...
        'position', [x_panel+170, y_base+456, 105, 25], 'fontsize', 10, ...
        'tag', 'content_re_beta');
    
    // Nose radius
    uicontrol(fig, 'style', 'text', 'string', 'Nose Radius (m):', ...
        'position', [x_panel, y_base+428, 170, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl5');
    uicontrol(fig, 'style', 'edit', 'string', '1.0', ...
        'position', [x_panel+170, y_base+426, 105, 25], 'fontsize', 10, ...
        'tag', 'content_re_rnose');
    
    // Vehicle presets
    uicontrol(fig, 'style', 'text', 'string', 'Vehicle Preset:', ...
        'position', [x_panel, y_base+398, 120, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl6');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Custom|Apollo CM|Soyuz|Crew Dragon|Mars Curiosity|Stardust', ...
        'position', [x_panel+120, y_base+396, 155, 25], 'fontsize', 10, ...
        'tag', 'content_re_v_preset', 'callback', 'cb_reentry_vehicle_preset()');
    
    // Plot type
    uicontrol(fig, 'style', 'text', 'string', 'Plot:', ...
        'position', [x_panel, y_base+368, 50, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_re_lbl7');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Velocity vs Altitude|G-Loading vs Altitude|Heat Flux vs Altitude|All Plots', ...
        'position', [x_panel+50, y_base+366, 225, 25], 'fontsize', 10, ...
        'tag', 'content_re_plottype');
    
    // ---- Analyze Button ----
    uicontrol(fig, 'style', 'pushbutton', ...
        'string', '🔥 ANALYZE RE-ENTRY', ...
        'position', [x_panel, y_base+325, panel_w, 35], ...
        'fontsize', 12, 'fontweight', 'bold', ...
        'background', [0.2, 0.7, 0.7], 'foreground', [1, 1, 1], ...
        'callback', 'cb_analyze_reentry()', ...
        'tag', 'content_re_analyze');
    
    // ---- Results ----
    uicontrol(fig, 'style', 'text', 'string', '■ RE-ENTRY RESULTS', ...
        'position', [x_panel, y_base+295, panel_w, 22], ...
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ...
        'foreground', [0.1, 0.6, 0.6], 'tag', 'content_re_res_title');
    
    res_labels = ['Peak Decel Alt:  —         '; ...
                  'Peak G-Loading:  —         '; ...
                  'V at Peak Decel: —         '; ...
                  'Peak Heat Flux:  —         '; ...
                  'Total Heat Load: —         '; ...
                  'Survivable:      —         '];
    
    for k = 1:6
        uicontrol(fig, 'style', 'text', ...
            'string', res_labels(k,:), ...
            'position', [x_panel, y_base+295-k*23, panel_w, 20], ...
            'fontsize', 9, 'horizontalalignment', 'left', ...
            'fontname', 'Consolas', ...
            'tag', 'content_re_result_' + string(k));
    end
    
    // Plot placeholder
    uicontrol(fig, 'style', 'text', ...
        'string', 'Re-entry analysis plots will appear here', ...
        'position', [310, y_base+300, 870, 40], ...
        'fontsize', 14, 'horizontalalignment', 'center', ...
        'foreground', [0.5, 0.5, 0.6], ...
        'tag', 'content_re_plot_placeholder');
    
endfunction


function cb_reentry_vehicle_preset()
    // Apply vehicle presets
    preset = get(findobj('tag', 'content_re_v_preset'), 'value');
    
    // [beta (kg/m^2), nose_radius (m), v_entry (km/s), gamma (deg)]
    select preset
    case 2  // Apollo CM
        set(findobj('tag', 'content_re_beta'), 'string', '370');
        set(findobj('tag', 'content_re_rnose'), 'string', '4.69');
        set(findobj('tag', 'content_re_v_entry'), 'string', '11.0');
        set(findobj('tag', 'content_re_gamma'), 'string', '-6.5');
    case 3  // Soyuz
        set(findobj('tag', 'content_re_beta'), 'string', '210');
        set(findobj('tag', 'content_re_rnose'), 'string', '2.2');
        set(findobj('tag', 'content_re_v_entry'), 'string', '7.7');
        set(findobj('tag', 'content_re_gamma'), 'string', '-3.5');
    case 4  // Crew Dragon
        set(findobj('tag', 'content_re_beta'), 'string', '280');
        set(findobj('tag', 'content_re_rnose'), 'string', '3.7');
        set(findobj('tag', 'content_re_v_entry'), 'string', '7.8');
        set(findobj('tag', 'content_re_gamma'), 'string', '-4.0');
    case 5  // Curiosity MSL
        set(findobj('tag', 'content_re_beta'), 'string', '140');
        set(findobj('tag', 'content_re_rnose'), 'string', '2.25');
        set(findobj('tag', 'content_re_v_entry'), 'string', '5.8');
        set(findobj('tag', 'content_re_gamma'), 'string', '-15.5');
        set(findobj('tag', 'content_re_planet'), 'value', 2);  // Mars
    case 6  // Stardust
        set(findobj('tag', 'content_re_beta'), 'string', '60');
        set(findobj('tag', 'content_re_rnose'), 'string', '0.23');
        set(findobj('tag', 'content_re_v_entry'), 'string', '12.9');
        set(findobj('tag', 'content_re_gamma'), 'string', '-8.2');
    end
endfunction


function cb_analyze_reentry()
    // Run re-entry analysis
    
    // Read inputs
    planet_id = get(findobj('tag', 'content_re_planet'), 'value');
    if planet_id == 1 then planet = "Earth"; else planet = "Mars"; end
    
    v_entry = strtod(get(findobj('tag', 'content_re_v_entry'), 'string'));
    gamma = strtod(get(findobj('tag', 'content_re_gamma'), 'string'));
    h_entry = strtod(get(findobj('tag', 'content_re_h_entry'), 'string'));
    beta_kgm2 = strtod(get(findobj('tag', 'content_re_beta'), 'string'));
    R_nose = strtod(get(findobj('tag', 'content_re_rnose'), 'string'));
    
    // Convert ballistic coefficient from kg/m^2 to kg/km^2
    beta = beta_kgm2 * 1e6;
    
    // Run analysis
    result = ballistic_entry(v_entry, gamma, h_entry, beta, R_nose, planet);
    
    // Update results
    set(findobj('tag', 'content_re_result_1'), 'string', ...
        msprintf('Peak Decel Alt: %.1f km', result.h_peak_decel));
    set(findobj('tag', 'content_re_result_2'), 'string', ...
        msprintf('Peak G-Loading: %.1f g', result.g_loading));
    set(findobj('tag', 'content_re_result_3'), 'string', ...
        msprintf('V at Peak:      %.3f km/s', result.v_peak_decel));
    set(findobj('tag', 'content_re_result_4'), 'string', ...
        msprintf('Peak Heat Flux: %.1f kW/m²', result.q_peak));
    set(findobj('tag', 'content_re_result_5'), 'string', ...
        msprintf('Heat Load:      %.0f kJ/m²', result.Q_total));
    
    if result.g_loading < 10 then
        set(findobj('tag', 'content_re_result_6'), 'string', ...
            '✅ Survivable: Yes (< 10g)');
    elseif result.g_loading < 20 then
        set(findobj('tag', 'content_re_result_6'), 'string', ...
            '⚠️ Survivable: Marginal (10-20g)');
    else
        set(findobj('tag', 'content_re_result_6'), 'string', ...
            '❌ Survivable: Extreme (> 20g)');
    end
    
    // Plot
    ph = findobj('tag', 'content_re_plot_placeholder');
    if ph <> [] then set(ph, 'visible', 'off'); end
    
    plot_type = get(findobj('tag', 'content_re_plottype'), 'value');
    
    newaxes();
    ax = gca();
    ax.axes_bounds = [0.28, 0.05, 0.70, 0.90];
    
    select plot_type
    case 1
        // Velocity vs altitude
        plot(result.v_traj, result.h_traj, 'b-', 'LineWidth', 2);
        xlabel('Velocity [km/s]');
        ylabel('Altitude [km]');
        title('Entry Velocity Profile');
        xgrid();
        
    case 2
        // G-Loading vs altitude
        g_load = result.a_traj / 9.80665e-3;
        plot(g_load, result.h_traj, 'r-', 'LineWidth', 2);
        xlabel('Deceleration [g]');
        ylabel('Altitude [km]');
        title('G-Loading Profile');
        xgrid();
        
    case 3
        // Heat flux vs altitude
        plot(result.q_traj, result.h_traj, 'm-', 'LineWidth', 2);
        xlabel('Heat Flux [kW/m²]');
        ylabel('Altitude [km]');
        title('Stagnation Point Heat Flux');
        xgrid();
        
    case 4
        // All plots
        subplot(131);
        plot(result.v_traj, result.h_traj, 'b-', 'LineWidth', 2);
        xlabel('V [km/s]'); ylabel('Alt [km]'); title('Velocity');
        xgrid();
        
        subplot(132);
        g_load = result.a_traj / 9.80665e-3;
        plot(g_load, result.h_traj, 'r-', 'LineWidth', 2);
        xlabel('G-load [g]'); ylabel('Alt [km]'); title('G-Loading');
        xgrid();
        
        subplot(133);
        plot(result.q_traj, result.h_traj, 'm-', 'LineWidth', 2);
        xlabel('q [kW/m²]'); ylabel('Alt [km]'); title('Heat Flux');
        xgrid();
    end
    
    update_status(msprintf('Re-entry analysis: Peak %.1f g at %.0f km, Peak heat flux %.0f kW/m²', ...
        result.g_loading, result.h_peak_decel, result.q_peak));
    
endfunction
