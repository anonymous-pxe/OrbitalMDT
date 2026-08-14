// ============================================================================
// OrbitalMDT — Hohmann & Bi-Elliptic Transfer Tab
// ============================================================================

function build_hohmann_tab(fig)
    // Build the Transfers tab content
    
    y_base = 25;
    x_panel = 15;
    panel_w = 280;
    
    // ---- Section Title ----
    uicontrol(fig, 'style', 'text', 'string', '■ HOHMANN TRANSFER', ...
        'position', [x_panel, y_base+660, panel_w, 22], ...
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ...
        'foreground', [0.2, 0.7, 0.3], 'tag', 'content_ht_title');
    
    // Transfer type
    uicontrol(fig, 'style', 'text', 'string', 'Transfer Type:', ...
        'position', [x_panel, y_base+632, 120, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl0');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Hohmann (2-burn)|Bi-Elliptic (3-burn)', ...
        'position', [x_panel+120, y_base+630, 155, 25], 'fontsize', 10, ...
        'tag', 'content_ht_type', 'callback', 'cb_transfer_type_changed()');
    
    // Orbit type selector
    uicontrol(fig, 'style', 'text', 'string', 'Orbit System:', ...
        'position', [x_panel, y_base+600, 120, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl00');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Earth Orbit (km)|Heliocentric (AU)|Custom mu', ...
        'position', [x_panel+120, y_base+598, 155, 25], 'fontsize', 10, ...
        'value', 1, 'tag', 'content_ht_system');
    
    // ---- Orbit Radii ----
    uicontrol(fig, 'style', 'text', 'string', 'Initial Orbit Radius:', ...
        'position', [x_panel, y_base+565, 150, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl1');
    uicontrol(fig, 'style', 'edit', 'string', '6571', ...
        'position', [x_panel+150, y_base+563, 125, 25], 'fontsize', 10, ...
        'tag', 'content_ht_r1');
    
    uicontrol(fig, 'style', 'text', 'string', 'Final Orbit Radius:', ...
        'position', [x_panel, y_base+535, 150, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl2');
    uicontrol(fig, 'style', 'edit', 'string', '42164', ...
        'position', [x_panel+150, y_base+533, 125, 25], 'fontsize', 10, ...
        'tag', 'content_ht_r2');
    
    // Bi-elliptic intermediate radius
    uicontrol(fig, 'style', 'text', 'string', 'Intermediate Radius:', ...
        'position', [x_panel, y_base+505, 150, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl3', ...
        'visible', 'off');
    uicontrol(fig, 'style', 'edit', 'string', '100000', ...
        'position', [x_panel+150, y_base+503, 125, 25], 'fontsize', 10, ...
        'tag', 'content_ht_r_int', 'visible', 'off');
    
    // Quick presets
    uicontrol(fig, 'style', 'text', 'string', 'Quick Presets:', ...
        'position', [x_panel, y_base+470, 120, 20], 'fontsize', 10, ...
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl4');
    uicontrol(fig, 'style', 'popupmenu', ...
        'string', 'Custom|LEO→GEO|LEO→MEO|LEO→Moon|Earth→Mars|Earth→Jupiter', ...
        'position', [x_panel+110, y_base+468, 165, 25], 'fontsize', 10, ...
        'tag', 'content_ht_presets', 'callback', 'cb_hohmann_preset()');
    
    // ---- Calculate Button ----
    uicontrol(fig, 'style', 'pushbutton', ...
        'string', '⚡ CALCULATE TRANSFER', ...
        'position', [x_panel, y_base+425, panel_w, 35], ...
        'fontsize', 12, 'fontweight', 'bold', ...
        'background', [0.2, 0.7, 0.3], 'foreground', [1, 1, 1], ...
        'callback', 'cb_calculate_transfer()', ...
        'tag', 'content_ht_calculate');
    
    // ---- Results ----
    uicontrol(fig, 'style', 'text', 'string', '■ RESULTS', ...
        'position', [x_panel, y_base+395, panel_w, 22], ...
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ...
        'foreground', [0.1, 0.5, 0.1], 'tag', 'content_ht_res_title');
    
    result_labels = ['ΔV₁ (1st burn):    —'; ...
                     'ΔV₂ (2nd burn):    —'; ...
                     'ΔV₃ (3rd burn):    —'; ...
                     'ΔV Total:          —'; ...
                     'Transfer Time:     —'; ...
                     'Transfer SMA:      —'; ...
                     'Transfer Ecc:      —'; ...
                     'Phase Angle:       —'; ...
                     'C₃ Departure:      —'; ...
                     'Hohmann Compare:   —'];
    
    for k = 1:10
        uicontrol(fig, 'style', 'text', ...
            'string', result_labels(k,:), ...
            'position', [x_panel, y_base+395-k*23, panel_w, 20], ...
            'fontsize', 10, 'horizontalalignment', 'left', ...
            'fontname', 'Consolas', ...
            'tag', 'content_ht_result_' + string(k));
    end
    
    // ---- Plot placeholder ----
    uicontrol(fig, 'style', 'text', ...
        'string', 'Transfer orbit diagram will appear here', ...
        'position', [310, y_base+300, 870, 40], ...
        'fontsize', 14, 'horizontalalignment', 'center', ...
        'foreground', [0.5, 0.5, 0.6], ...
        'tag', 'content_ht_plot_placeholder');
    
endfunction


function cb_transfer_type_changed()
    // Show/hide bi-elliptic intermediate radius field
    type_val = get(findobj('tag', 'content_ht_type'), 'value');
    if type_val == 2 then
        vis = 'on';
    else
        vis = 'off';
    end
    set(findobj('tag', 'content_ht_lbl3'), 'visible', vis);
    set(findobj('tag', 'content_ht_r_int'), 'visible', vis);
endfunction


function cb_hohmann_preset()
    // Apply quick preset values
    preset = get(findobj('tag', 'content_ht_presets'), 'value');
    
    select preset
    case 2  // LEO→GEO
        set(findobj('tag', 'content_ht_r1'), 'string', '6571');
        set(findobj('tag', 'content_ht_r2'), 'string', '42164');
        set(findobj('tag', 'content_ht_system'), 'value', 1);
    case 3  // LEO→MEO
        set(findobj('tag', 'content_ht_r1'), 'string', '6571');
        set(findobj('tag', 'content_ht_r2'), 'string', '26561');
        set(findobj('tag', 'content_ht_system'), 'value', 1);
    case 4  // LEO→Moon
        set(findobj('tag', 'content_ht_r1'), 'string', '6571');
        set(findobj('tag', 'content_ht_r2'), 'string', '384400');
        set(findobj('tag', 'content_ht_system'), 'value', 1);
    case 5  // Earth→Mars (heliocentric)
        set(findobj('tag', 'content_ht_r1'), 'string', '1.0');
        set(findobj('tag', 'content_ht_r2'), 'string', '1.524');
        set(findobj('tag', 'content_ht_system'), 'value', 2);
    case 6  // Earth→Jupiter
        set(findobj('tag', 'content_ht_r1'), 'string', '1.0');
        set(findobj('tag', 'content_ht_r2'), 'string', '5.203');
        set(findobj('tag', 'content_ht_system'), 'value', 2);
    end
endfunction


function cb_calculate_transfer()
    // Calculate Hohmann or Bi-elliptic transfer
    
    const = orbital_constants();
    
    // Read inputs
    r1_str = get(findobj('tag', 'content_ht_r1'), 'string');
    r2_str = get(findobj('tag', 'content_ht_r2'), 'string');
    r1 = strtod(r1_str);
    r2 = strtod(r2_str);
    
    sys = get(findobj('tag', 'content_ht_system'), 'value');
    
    select sys
    case 1
        mu = const.mu_Earth;
        unit = ' km';
    case 2
        mu = const.mu_Sun;
        r1 = r1 * const.AU;
        r2 = r2 * const.AU;
        unit = ' AU';
    case 3
        mu = const.mu_Earth;
        unit = ' km';
    end
    
    transfer_type = get(findobj('tag', 'content_ht_type'), 'value');
    
    if transfer_type == 1 then
        // Hohmann
        result = hohmann_transfer(r1, r2, mu);
        
        set(findobj('tag', 'content_ht_result_1'), 'string', ...
            msprintf('ΔV₁ (1st burn):  %.4f km/s', result.dv1));
        set(findobj('tag', 'content_ht_result_2'), 'string', ...
            msprintf('ΔV₂ (2nd burn):  %.4f km/s', result.dv2));
        set(findobj('tag', 'content_ht_result_3'), 'string', ...
            'ΔV₃ (3rd burn):  N/A (2-burn)');
        set(findobj('tag', 'content_ht_result_4'), 'string', ...
            msprintf('ΔV Total:        %.4f km/s', result.dv_total));
        
        // Format time
        t_hrs = result.t_transfer / 3600;
        if t_hrs > 24 then
            t_str = msprintf('%.1f days', t_hrs/24);
        else
            t_str = msprintf('%.1f hours', t_hrs);
        end
        set(findobj('tag', 'content_ht_result_5'), 'string', ...
            'Transfer Time:   ' + t_str);
        
        if sys == 2 then
            set(findobj('tag', 'content_ht_result_6'), 'string', ...
                msprintf('Transfer SMA:    %.4f AU', result.a_transfer/const.AU));
        else
            set(findobj('tag', 'content_ht_result_6'), 'string', ...
                msprintf('Transfer SMA:    %.1f km', result.a_transfer));
        end
        set(findobj('tag', 'content_ht_result_7'), 'string', ...
            msprintf('Transfer Ecc:    %.6f', result.e_transfer));
        set(findobj('tag', 'content_ht_result_8'), 'string', ...
            msprintf('Phase Angle:     %.2f°', result.phase_angle_deg));
        set(findobj('tag', 'content_ht_result_9'), 'string', ...
            msprintf('C₃ Departure:    %.3f km²/s²', result.C3_departure));
        set(findobj('tag', 'content_ht_result_10'), 'string', '');
        
        // Plot transfer orbit
        ph = findobj('tag', 'content_ht_plot_placeholder');
        if ph <> [] then set(ph, 'visible', 'off'); end
        
        plot_hohmann_orbit(r1, r2, result);
        
    else
        // Bi-elliptic
        r_int_str = get(findobj('tag', 'content_ht_r_int'), 'string');
        r_int = strtod(r_int_str);
        if sys == 2 then r_int = r_int * const.AU; end
        
        result = bielliptic_transfer(r1, r2, r_int, mu);
        
        set(findobj('tag', 'content_ht_result_1'), 'string', ...
            msprintf('ΔV₁ (1st burn):  %.4f km/s', result.dv1));
        set(findobj('tag', 'content_ht_result_2'), 'string', ...
            msprintf('ΔV₂ (2nd burn):  %.4f km/s', result.dv2));
        set(findobj('tag', 'content_ht_result_3'), 'string', ...
            msprintf('ΔV₃ (3rd burn):  %.4f km/s', result.dv3));
        set(findobj('tag', 'content_ht_result_4'), 'string', ...
            msprintf('ΔV Total:        %.4f km/s', result.dv_total));
        
        t_hrs = result.t_total / 3600;
        if t_hrs > 24 then
            t_str = msprintf('%.1f days', t_hrs/24);
        else
            t_str = msprintf('%.1f hours', t_hrs);
        end
        set(findobj('tag', 'content_ht_result_5'), 'string', ...
            'Transfer Time:   ' + t_str);
        set(findobj('tag', 'content_ht_result_6'), 'string', ...
            msprintf('SMA₁: %.1f  SMA₂: %.1f', result.a1, result.a2));
        set(findobj('tag', 'content_ht_result_7'), 'string', ...
            msprintf('Ratio r2/r1:     %.2f', result.ratio));
        set(findobj('tag', 'content_ht_result_8'), 'string', ...
            msprintf('Hohmann ΔV:      %.4f km/s', result.dv_hohmann));
        set(findobj('tag', 'content_ht_result_9'), 'string', ...
            msprintf('ΔV Savings:      %.4f km/s', result.dv_savings));
        
        if result.is_better then
            set(findobj('tag', 'content_ht_result_10'), 'string', ...
                '✅ Bi-elliptic is MORE efficient!');
        else
            set(findobj('tag', 'content_ht_result_10'), 'string', ...
                '❌ Hohmann is more efficient');
        end
    end
    
    update_status('Transfer calculation complete.');
    
endfunction


function plot_hohmann_orbit(r1, r2, result)
    // Plot the Hohmann transfer orbit diagram
    
    newaxes();
    a = gca();
    a.axes_bounds = [0.28, 0.05, 0.70, 0.90];
    a.isoview = 'on';
    
    // Draw orbits
    theta = linspace(0, 2*%pi, 200);
    
    // Initial orbit (circle)
    x1 = r1 * cos(theta);
    y1 = r1 * sin(theta);
    plot(x1, y1, 'b-', 'LineWidth', 1.5);
    
    // Final orbit (circle)
    x2 = r2 * cos(theta);
    y2 = r2 * sin(theta);
    plot(x2, y2, 'r-', 'LineWidth', 1.5);
    
    // Transfer ellipse (half)
    a_t = result.a_transfer;
    e_t = result.e_transfer;
    theta_t = linspace(0, %pi, 200);
    r_t = a_t * (1 - e_t^2) ./ (1 + e_t * cos(theta_t));
    x_t = r_t .* cos(theta_t);
    y_t = r_t .* sin(theta_t);
    plot(x_t, y_t, 'g--', 'LineWidth', 2.5);
    
    // Central body
    plot(0, 0, 'yo', 'MarkerSize', 12, 'MarkerFaceColor', [1, 0.8, 0]);
    
    // Burn points
    plot(r1, 0, 'b^', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    plot(-r2, 0, 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    
    legend(['Initial Orbit', 'Final Orbit', 'Transfer Orbit'], 'in_upper_left');
    title('Hohmann Transfer Orbit Diagram');
    xlabel('x [km]');
    ylabel('y [km]');
    
endfunction
